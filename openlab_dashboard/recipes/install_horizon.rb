#
# Cookbook Name:: openlab_dashboard
# Recipe:: install_horizon
#
# Copyright (c) 2016 The Authors, All Rights Reserved.


#Install Horizon
%w(openstack-dashboard).each do |pkg|
  package pkg do
    action [ :install ]
  end
end


template "/etc/openstack-dashboard/local_settings.py" do
  source "local_settings.py.erb"
  owner 'horizon'
  group 'horizon'
  mode 0711
  notifies :reload, 'service[apache2]', :delayed
end


#SERVICES

service "apache2" do
  action :nothing
end


