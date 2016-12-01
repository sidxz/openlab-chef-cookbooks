#
# Cookbook Name:: openlab_nova
# Recipe:: configure_controller
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

# create my sql database
template "/root/.chefvars/openlab_compute-install-nova-prereq.sql" do
  source "dbase.sql.erb"
  owner 'root'
  group 'root'
  mode 0700
  variables :nova_dbpass => node['openlab-compute']['install']['nova-dp-pass']
end


# Execute SQL Script
execute "Run_SQL_Prereq" do
  command "mysql --user=root < /root/.chefvars/openlab_compute-install-nova-prereq.sql && touch /root/.chefvars/openlab_compute-install-nova-prereq.bool"
  live_stream true
  not_if {::File.exist?("/root/.chefvars/openlab_compute-install-nova-prereq.bool")}
end

credentials = node['openlab-global']['admin-credentials']
projectParams = node['openlab-global']['project-params']

#Create the nova user:
execute "user-create-nova" do
  command <<-EOH
  openstack user create --domain default --password=#{node['openlab-compute']['install']['nova-user-pass']} #{credentials} #{projectParams} nova && touch /root/.chefvars/openlab_compute-user-create-nova.bool
  EOH
  live_stream true
  not_if {::File.exist?("/root/.chefvars/openlab_compute-user-create-nova.bool")}
end

#Add the admin role to the nova user and service project
execute "add-nova-to-service-project" do
  command <<-EOH
  openstack role add --project service --user nova #{credentials} #{projectParams} admin && touch /root/.chefvars/openlab_compute-add-nova-to-service-project.bool
  EOH
  live_stream true
  not_if {::File.exist?("/root/.chefvars/openlab_compute-add-nova-to-service-project.bool")}
end



#Create the nova service entity
execute "service-create-nova" do
  command <<-EOH
  openstack service create --name nova --description "Openstack compute" #{credentials} #{projectParams} compute && touch /root/.chefvars/openlab_compute-service-create-nova.bool
  EOH
  live_stream true
  not_if {::File.exist?("/root/.chefvars/openlab_compute-service-create-nova.bool")}
end

%w(public internal admin).each do |key|
	execute "endpoint-create-nova" do
  		command <<-EOH
  openstack endpoint create --region RegionOne compute #{key} http://openlab-controller:8774/v2.1/%\\(tenant_id\\)s #{credentials} #{projectParams} && touch /root/.chefvars/openlab_compute-endpoint-create-nova-#{key}.bool
  EOH
  	live_stream true
    not_if {::File.exist?("/root/.chefvars/openlab_compute-endpoint-create-nova-#{key}.bool")}
	end 	
end

#Install nova
%w(nova-api nova-conductor nova-consoleauth nova-novncproxy nova-scheduler).each do |pkg|
  package pkg do
    action [ :install ]
  end
end

#Configure nova
template "/etc/nova/nova.conf" do
  source "nova_controller.conf.erb"
  owner 'nova'
  group 'nova'
  mode 0711
  variables :nova_dbpass => node['openlab-compute']['install']['nova-dp-pass'], :nova_user_pass => node['openlab-compute']['install']['nova-user-pass'], :rabbit_pass => node['com_rabbitmq']['rabbit_pass'], :neutron_user_pass => node['openlab-compute']['install']['neutron-user-pass'], :metadata_proxy_secret => node['openlab-compute']['metadata']['proxy-secret']
  notifies :restart, 'service[nova-api]', :delayed
  notifies :restart, 'service[nova-consoleauth]', :delayed
  notifies :restart, 'service[nova-scheduler]', :delayed
  notifies :restart, 'service[nova-conductor]', :delayed
  notifies :restart, 'service[nova-novncproxy]', :delayed
end

execute "nova_api_db_sync" do
  command "su -s /bin/sh -c \"nova-manage api_db sync\" nova && touch /root/.chefvars/openlab_identity-install-nova-api-dbsync.bool"
  live_stream true
  not_if {::File.exist?("/root/.chefvars/openlab_identity-install-nova-api-dbsync.bool")}
  notifies :restart, 'service[nova-api]', :delayed
  notifies :restart, 'service[nova-consoleauth]', :delayed
  notifies :restart, 'service[nova-scheduler]', :delayed
  notifies :restart, 'service[nova-conductor]', :delayed
  notifies :restart, 'service[nova-novncproxy]', :delayed
end
execute "nova_db_sync" do
  command "su -s /bin/sh -c \"nova-manage db sync\" nova && touch /root/.chefvars/openlab_identity-install-nova-dbsync.bool"
  live_stream true
  not_if {::File.exist?("/root/.chefvars/openlab_identity-install-nova-dbsync.bool")}
  notifies :restart, 'service[nova-api]', :immediate
  notifies :restart, 'service[nova-consoleauth]', :immediate
  notifies :restart, 'service[nova-scheduler]', :immediate
  notifies :restart, 'service[nova-conductor]', :immediate
  notifies :restart, 'service[nova-novncproxy]', :immediate
end


#SERVICES

service "nova-consoleauth" do
  action :nothing
end

service "nova-api" do
  action :nothing
end

service "nova-scheduler" do
  action :nothing
end

service "nova-conductor" do
  action :nothing
end

service "nova-novncproxy" do
  action :nothing
end
