#
# Cookbook Name:: openlab-utils
# Recipe:: memcached
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

package %w{memcached python-memcache} do
  action [ :install ]
end

template "/etc/memcached.conf" do
  source "memcached.conf.erb"
  owner 'root'
  group 'root'
  mode 0700
  variables :ip_address => node['openlab-utils']['memcached']['bind-ip']
  notifies :restart, 'service[memcached]', :delayed
end

service "memcached" do
  action :nothing
end