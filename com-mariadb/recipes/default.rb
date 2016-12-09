#
# Cookbook Name:: com-mariadb
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

package "software-properties-common" do
  action [ :install ]
end

# apt_repository 'maria-db' do
#   uri 'http://ftp.utexas.edu/mariadb/repo/10.1/ubuntu'
#   components ['main']
#   distribution 'xenial'
#   key '0xF1656F24C74CD1D8'
#   keyserver 'keyserver.ubuntu.com'
#   action :add
#   deb_src true
# end

package "mariadb-server" do
  action [ :install ]
end

package "python-pymysql" do
  action [ :install ]
end

template "/etc/mysql/mariadb.conf.d/99-openstack.cnf" do
  source "99-openstack.cnf.erb"
  owner 'root'
  group 'root'
  mode 0600
  variables :bind_address => node['com-mariadb']['mysql-bind-address']
  notifies :restart, 'service[mysql]', :delayed
end

cookbook_file '/etc/mysql/mariadb.conf.d/50-server.cnf' do
  source '50-server.cnf'
  mode '0755'
  owner 'root'
  group 'root'
  notifies :restart, 'service[mysql]', :delayed
end

template "/tmp/mysql_secure_installation_silent.sh" do
  source "mysql_secure_installation_silent.sh.erb"
  owner 'root'
  group 'root'
  mode 0700
  variables :mysql_password => node['com-mariadb']['mysql-password']
end

directory '/root/.chefvars' do
  owner 'root'
  group 'root'
  mode '0700'
  action :create
end

execute 'mysql_secure_installation_silent' do
  command '/tmp/mysql_secure_installation_silent.sh && touch /root/.chefvars/mysql_secure_installation_silent.bool'
  not_if {::File.exist?("/root/.chefvars/mysql_secure_installation_silent.bool")}  
end


service "mysql" do
  action :nothing
end

