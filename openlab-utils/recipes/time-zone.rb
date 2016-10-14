#
# Cookbook Name:: openlab-utils
# Recipe:: time-zone
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

## Set time Zone 

include_recipe 'ntp::default'

case node['platform_family']
when 'debian'
bash 'set-time-zone' do
  code "sudo timedatectl set-timezone #{node['openlab-utils']['time-zone']}"
end

when 'rhel'
link '/etc/localtime' do 
  to "/usr/share/zoneinfo/#{node['openlab-utils']['time-zone']}"
  action :create
end
end
