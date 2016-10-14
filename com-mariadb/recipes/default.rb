#
# Cookbook Name:: com-mariadb
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

package "software-properties-common" do
  action [ :install ]
end

apt_repository 'maria-db' do
  uri 'http://ftp.utexas.edu/mariadb/repo/10.1/ubuntu xenial main'
#  components ['main']
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

