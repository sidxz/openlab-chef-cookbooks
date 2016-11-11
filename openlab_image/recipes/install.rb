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
  openstack user create --domain default --password=#{node['openlab-image']['install']['glance-user-pass']} #{credentials} #{projectParams} glance
  EOH
  live_stream true
end

#Add the admin role to the glance user and service project
execute "add-glance-to-service-project" do
  command <<-EOH
  openstack role add --project service --user glance #{credentials} #{projectParams} admin
  EOH
  live_stream true
end

#Create the glance service entity
execute "service-create-glance" do
  command <<-EOH
  openstack service create --name glance --description "Openstack image" #{credentials} #{projectParams} image
  EOH
  live_stream true
end

%w(public internal admin).each do |key|
	execute "service-create-glance" do
  		command <<-EOH
  openstack endpoint create --region RegionOne image #{key} http://openlab-controller:9292 #{credentials} #{projectParams}
  EOH
  	live_stream true
	end	
end

#Install glance
package "openstack-glance" do
  action [ :install ]
end



