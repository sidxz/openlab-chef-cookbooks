#
# Cookbook Name:: com-mariadb
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

package "software-properties-common" do
  action [ :install ]
end

apt_repository 'maria-db' do
  uri 'http://ftp.utexas.edu/mariadb/repo/10.1/ubuntu'
  components ['main']
  distribution 'xenial'
  key '0xF1656F24C74CD1D8'
  keyserver 'keyserver.ubuntu.com'
  action :add
  deb_src true
end

package "mariadb-server" do
  action [ :install ]
end

package "python-mysqldb" do
  action [ :install ]
end

template "/etc/mysql/my.cnf" do
  source "my.cnf.erb"
  owner 'root'
  group 'root'
  mode 0600
  variables :bind_address => node['com-mariadb']['mysql-bind-address']
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

