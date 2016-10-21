#
# Cookbook Name:: openlab_identity
# Recipe:: install
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

#Before you configure the OpenStack Identity service, you must create a database and an administration token.

# create my sql database
template "/root/.chefvars/openlab_identity-install-keystone-prereq.sql" do
  source "dbase.sql.erb"
  owner 'root'
  group 'root'
  mode 0700
  variables :keystone_dbpass => node['openlab-identity']['install']['keystone-dp-pass']
end

# Execute SQL Script
execute "Run_SQL_Prereq" do
  command "mysql --user=root < /root/.chefvars/openlab_identity-install-keystone-prereq.sql && touch /root/.chefvars/openlab_identity-install-keystone-prereq.bool"
  live_stream true
  not_if {::File.exist?("/root/.chefvars/openlab_identity-install-keystone-prereq.bool")}
end

#Install Keystone
package "keystone" do
  action [ :install ]
end

template "/etc/keystone/keystone.conf" do
  source "keystone.conf.erb"
  owner 'keystone'
  group 'keystone'
  mode 0700
  variables :keystone_dbpass => node['openlab-identity']['install']['keystone-dp-pass']
end

#su -s /bin/sh -c "keystone-manage db_sync" keystone
execute "keystone_db_sync" do
  command "su -s /bin/sh -c \"keystone-manage db_sync\" keystone && touch /root/.chefvars/openlab_identity-install-keystone-dbsync.bool"
  live_stream true
  not_if {::File.exist?("/root/.chefvars/openlab_identity-install-keystone-dbsync.bool")}
end


