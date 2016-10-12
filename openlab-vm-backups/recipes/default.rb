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

node['openlab-vm-backup']['dirs'].each do |dir|
  directory "/backups/#{dir}" do
    owner 'root'
    group 'root'
    mode '0755'
    recursive true
    not_if do ::Dir.exist?(dir) end
  end
end

#TODO: Add ssh keys

coe_lwrp_ssh_user "sidx" do
    cookbook_name 'openlab-vm-backups' 
    server 'openlab.cs.tamu.edu'
    private_key 'id_rsa'
    public_key 'id_rsa.pub'
    known_host node['openlab-vm-backup']['ssh-finger-print']
    user "sidx"  
    action :add
end

#Install and enable cron
### Start crond
package "cronie"
service "crond" do
  action [:start, :enable]
end

#crontab to create snapshot
cron "create-snapshot-daily" do 
  minute "45"
  hour "2"
  day "*"
  month "*"
  weekday "1-7"
  command "/mnt/vms/scripts/create_snapshots.sh"
end

cron "rsync-backup-daily" do
  minute "45"
  hour "3"
  day "*"
  month "*"
  weekday "1-7"
  command "/mnt/vms/scripts/rsync_backups.sh"
end
