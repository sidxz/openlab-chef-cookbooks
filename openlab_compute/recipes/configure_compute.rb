#
# Cookbook Name:: openlab_nova
# Recipe:: configure_compute
#
# Copyright (c) 2016 The Authors, All Rights Reserved.


#Install nova
%w(nova-compute nova-compute-lxd).each do |pkg|
  package pkg do
    action [ :install ]
  end
end

#Configure nova
template "/etc/nova/nova.conf" do
  source "nova_compute.conf.erb"
  owner 'nova'
  group 'nova'
  mode 0711
  variables :nova_user_pass => node['openlab-compute']['install']['nova-user-pass'], :rabbit_pass => node['com_rabbitmq']['rabbit_pass']
  notifies :restart, 'service[nova-compute]', :delayed
end

#SERVICES

service "nova-compute" do
  action :nothing
end