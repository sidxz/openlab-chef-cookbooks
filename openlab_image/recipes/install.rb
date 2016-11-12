#
# Cookbook Name:: openlab_image
# Recipe:: install
#
# Copyright (c) 2016 The Authors, All Rights Reserved.


# create my sql database
template "/root/.chefvars/openlab_image-install-glance-prereq.sql" do
  source "dbase.sql.erb"
  owner 'root'
  group 'root'
  mode 0700
  variables :glance_dbpass => node['openlab-image']['install']['glance-dp-pass']
end

# Execute SQL Script
execute "Run_SQL_Prereq" do
  command "mysql --user=root < /root/.chefvars/openlab_image-install-glance-prereq.sql && touch /root/.chefvars/openlab_image-install-glance-prereq.bool"
  live_stream true
  not_if {::File.exist?("/root/.chefvars/openlab_image-install-glance-prereq.bool")}
end

credentials = node['openlab-global']['admin-credentials']
projectParams = node['openlab-global']['project-params']

#Create the glance user:
execute "user-create-glance" do
  command <<-EOH
  openstack user create --domain default --password=#{node['openlab-image']['install']['glance-user-pass']} #{credentials} #{projectParams} glance && touch /root/.chefvars/openlab_image-user-create-glance.bool
  EOH
  live_stream true
  not_if {::File.exist?("/root/.chefvars/openlab_image-user-create-glance.bool")}
end

#Add the admin role to the glance user and service project
execute "add-glance-to-service-project" do
  command <<-EOH
  openstack role add --project service --user glance #{credentials} #{projectParams} admin && touch /root/.chefvars/openlab_image-add-glance-to-service-project.bool
  EOH
  live_stream true
  not_if {::File.exist?("/root/.chefvars/openlab_image-add-glance-to-service-project.bool")}
end

#Create the glance service entity
execute "service-create-glance" do
  command <<-EOH
  openstack service create --name glance --description "Openstack image" #{credentials} #{projectParams} image && touch /root/.chefvars/openlab_image-service-create-glance.bool
  EOH
  live_stream true
  not_if {::File.exist?("/root/.chefvars/openlab_image-service-create-glance.bool")}
end

%w(public internal admin).each do |key|
	execute "endpoint-create-glance" do
  		command <<-EOH
  openstack endpoint create --region RegionOne image #{key} http://openlab-controller:9292 #{credentials} #{projectParams} && touch /root/.chefvars/openlab_image-endpoint-create-glance.bool
  EOH
  	live_stream true
    not_if {::File.exist?("/root/.chefvars/openlab_image-endpoint-create-glance.bool")}
	end 	
end

#Install glance
package "glance" do
  action [ :install ]
end

#Configure glance
template "/etc/glance/glance-api.conf" do
  source "glance-api.conf.erb"
  owner 'glance'
  group 'glance'
  mode 0711
  variables :glance_dbpass => node['openlab-image']['install']['glance-dp-pass'], :glance_user_pass => node['openlab-image']['install']['glance-user-pass']
  notifies :restart, 'service[glance-registry]', :delayed
  notifies :restart, 'service[glance-api]', :delayed
end

template "/etc/glance/glance-registry.conf" do
  source "glance-registry.conf.erb"
  owner 'glance'
  group 'glance'
  mode 0711
  variables :glance_dbpass => node['openlab-image']['install']['glance-dp-pass'], :glance_user_pass => node['openlab-image']['install']['glance-user-pass']
  notifies :restart, 'service[glance-registry]', :delayed
  notifies :restart, 'service[glance-api]', :delayed
end

execute "glance_db_sync" do
  command "su -s /bin/sh -c \"glance-manage db_sync\" glance && touch /root/.chefvars/openlab_identity-install-glance-dbsync.bool"
  live_stream true
  not_if {::File.exist?("/root/.chefvars/openlab_identity-install-glance-dbsync.bool")}
  notifies :restart, 'service[glance-registry]', :delayed
  notifies :restart, 'service[glance-api]', :delayed
end


#SERVICES

service "glance-registry" do
  action :nothing
end

service "glance-api" do
  action :nothing
end

