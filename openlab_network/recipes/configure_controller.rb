#
# Cookbook Name:: openlab_network
# Recipe:: configure_controller
#
# Copyright (c) 2016 The Authors, All Rights Reserved.


# create my sql database
template "/root/.chefvars/openlab_network-install-neutron-prereq.sql" do
  source "dbase.sql.erb"
  owner 'root'
  group 'root'
  mode 0700
  variables :neutron_dbpass => node['openlab-network']['install']['neutron-dp-pass']
end


# Execute SQL Script
execute "Run_SQL_Prereq" do
  command "mysql --user=root < /root/.chefvars/openlab_network-install-neutron-prereq.sql && touch /root/.chefvars/openlab_network-install-neutron-prereq.bool"
  live_stream true
  not_if {::File.exist?("/root/.chefvars/openlab_network-install-neutron-prereq.bool")}
end

credentials = node['openlab-global']['admin-credentials']
projectParams = node['openlab-global']['project-params']

#Create the neutron user:
execute "user-create-neutron" do
  command <<-EOH
  openstack user create --domain default --password=#{node['openlab-network']['install']['neutron-user-pass']} #{credentials} #{projectParams} neutron && touch /root/.chefvars/openlab_network-user-create-neutron.bool
  EOH
  live_stream true
  not_if {::File.exist?("/root/.chefvars/openlab_network-user-create-neutron.bool")}
end

#Add the admin role to the neutron user and service project
execute "add-neutron-to-service-project" do
  command <<-EOH
  openstack role add --project service --user neutron #{credentials} #{projectParams} admin && touch /root/.chefvars/openlab_network-add-neutron-to-service-project.bool
  EOH
  live_stream true
  not_if {::File.exist?("/root/.chefvars/openlab_network-add-neutron-to-service-project.bool")}
end



#Create the neutron service entity
execute "service-create-neutron" do
  command <<-EOH
  openstack service create --name neutron --description "Openstack networking" #{credentials} #{projectParams} network && touch /root/.chefvars/openlab_network-service-create-neutron.bool
  EOH
  live_stream true
  not_if {::File.exist?("/root/.chefvars/openlab_network-service-create-neutron.bool")}
end

%w(public internal admin).each do |key|
	execute "endpoint-create-neutron" do
  		command <<-EOH
  openstack endpoint create --region RegionOne network #{key} http://openlab-controller:9696 #{credentials} #{projectParams} && touch /root/.chefvars/openlab_network-endpoint-create-neutron-#{key}.bool
  EOH
  	live_stream true
    not_if {::File.exist?("/root/.chefvars/openlab_network-endpoint-create-neutron-#{key}.bool")}
	end 	
end

#Install Neutron
%w(neutron-server neutron-plugin-ml2 neutron-linuxbridge-agent neutron-dhcp-agent neutron-metadata-agent).each do |pkg|
  package pkg do
    action [ :install ]
  end
end


#Configure neutron
#TODO : change nova_user_pass to be global
template "/etc/neutron/neutron.conf" do
  source "neutron_controller.conf.erb"
  owner 'neutron'
  group 'neutron'
  mode 0711
  variables :neutron_dbpass => node['openlab-network']['install']['neutron-dp-pass'], :nova_user_pass => node['openlab-network']['install']['nova-user-pass'], :rabbit_pass => node['com_rabbitmq']['rabbit_pass'], :neutron_user_pass => node['openlab-network']['install']['neutron-user-pass']
end

#Configure the Modular Layer 2 (ML2) plug-in
template "/etc/neutron/plugins/ml2/ml2_conf.ini" do
  source "ml2_conf.ini.erb"
  owner 'neutron'
  group 'neutron'
  mode 0711
end

#Configure the Linux bridge agent
template "/etc/neutron/plugins/ml2/linuxbridge_agent.ini" do
  source "linuxbridge_agent.ini.erb"
  owner 'neutron'
  group 'neutron'
  mode 0711
end

template "/etc/neutron/dhcp_agent.ini" do
  source "dhcp_agent.ini.erb"
  owner 'neutron'
  group 'neutron'
  mode 0711
end

template "/etc/neutron/metadata_agent.ini" do
  source "metadata_agent.ini.erb"
  owner 'neutron'
  group 'neutron'
  mode 0711
  variables :metadata_proxy_secret => node['openlab-network']['metadata']['proxy-secret']
end

execute "neutron_db_manage" do
  command "su -s /bin/sh -c \"neutron-db-manage --config-file /etc/neutron/neutron.conf --config-file /etc/neutron/plugins/ml2/ml2_conf.ini upgrade head\" neutron && touch /root/.chefvars/openlab_network-install-neutron-dbmanage.bool"
  live_stream true
  not_if {::File.exist?("/root/.chefvars/openlab_network-install-neutron-dbmanage.bool")}
  notifies :restart, 'service[nova-api]', :immediate
  notifies :restart, 'service[neutron-server]', :immediate
  notifies :restart, 'service[neutron-linuxbridge-agent]', :immediate
  # notifies :restart, 'service[neutron-dhcp-agent]', :delayed
  # notifies :restart, 'service[neutron-metadata-agent]', :delayed
end

service "nova-api" do
  action :nothing
end
service "neutron-server" do
  action :nothing
end
service "neutron-linuxbridge-agent" do
  action :nothing
end
service "neutron-dhcp-agent" do
  action :nothing
end
service "neutron-metadata-agent" do
  action :nothing
end





