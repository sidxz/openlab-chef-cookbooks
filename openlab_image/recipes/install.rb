#
# Cookbook Name:: openlab_image
# Recipe:: install
#
# Copyright (c) 2016 The Authors, All Rights Reserved.


# create my sql database
template "/root/.chefvars/openlab_image-install-glance-prereq.sql" do
  source "dbase.sql.erb"
  owner 'root'
  group 'root'
  mode 0700
  variables :glance_dbpass => node['openlab-image']['install']['glance-dp-pass']
end

# Execute SQL Script
execute "Run_SQL_Prereq" do
  command "mysql --user=root < /root/.chefvars/openlab_image-install-glance-prereq.sql && touch /root/.chefvars/openlab_image-install-glance-prereq.bool"
  live_stream true
  not_if {::File.exist?("/root/.chefvars/openlab_image-install-glance-prereq.bool")}
end

