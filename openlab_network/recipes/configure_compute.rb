#
# Cookbook Name:: openlab_network
# Recipe:: configure_compute
#
# Copyright (c) 2016 The Authors, All Rights Reserved.


#Install Neutron-Bridge
%w(neutron-linuxbridge-agent).each do |pkg|
  package pkg do
    action [ :install ]
  end
end



#Configure neutron
#TODO : change nova_user_pass to be global
template "/etc/neutron/neutron.conf" do
  source "neutron_compute.conf.erb"
  owner 'neutron'
  group 'neutron'
  mode 0711
  variables :rabbit_pass => node['com_rabbitmq']['rabbit_pass'], :neutron_user_pass => node['openlab-network']['install']['neutron-user-pass']
end

#Configure the Linux bridge agent
template "/etc/neutron/plugins/ml2/linuxbridge_agent.ini" do
  source "linuxbridge_agent_compute.ini.erb"
  owner 'neutron'
  group 'neutron'
  mode 0711
  notifies :restart, 'service[nova-compute]', :delayed
  notifies :restart, 'service[neutron-linuxbridge-agent]', :delayed
end

#SERVICES

service "nova-compute" do
  action :nothing
end

service "neutron-linuxbridge-agent" do
  action :nothing
end

