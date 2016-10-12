#
# Cookbook Name:: openlab-vm-backups
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

node['openlab-vm-backups']['packages'].each do |pkg|
  package pkg do
    action [ :install ]
  end
end

directory node['openlab-vm-backups']['mount-point']['backup'] do
  owner 'root'
  group 'root'
  mode '0755'
  recursive true
  not_if do ::Dir.exist?(node['openlab-vm-backups']['mount-point']['backup']) end
end

mount node['openlab-vm-backups']['mount-point']['backup'] do
  device node['openlab-vm-backups']['mount']['vms']
  fstype 'nfs'
  action [:mount, :enable]
end


  
