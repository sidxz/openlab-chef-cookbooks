#
# Cookbook Name:: com_rabbitmq
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

#Install the package:
package "rabbitmq-server" do
  action [ :install ]
end

# rabbitmqctl add_user openstack RABBIT_PASS

execute 'rabbitmq_add_user' do
  command "rabbitmqctl add_user openstack #{node['com_rabbitmq']['rabbit_pass']} && touch /root/.chefvars/rabbitmqUser.bool"
  not_if {::File.exist?("/root/.chefvars/rabbitmqUser.bool")}  
end

#rabbitmqctl set_permissions openstack ".*" ".*" ".*"

execute 'abbitmq_set_user_permission' do
  command "rabbitmqctl set_permissions openstack \".*\" \".*\" \".*\" && touch /root/.chefvars/rabbitmqUserPermissions.bool"
  not_if {::File.exist?("/root/.chefvars/rabbitmqUserPermissions.bool")}  
end
