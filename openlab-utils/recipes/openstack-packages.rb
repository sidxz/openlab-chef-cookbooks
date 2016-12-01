#
# Cookbook Name:: openlab-utils
# Recipe:: openstack-packages
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

package "software-properties-common" do
  action [ :install ]
end

# apt_repository 'cloud-archive' do
#   uri "cloud-archive:newton"
# end

bash 'apt-add-cloud-archive' do
  code "add-apt-repository cloud-archive:newton"
end

bash 'apt-update' do
  code "apt-get update"
end

# bash 'apt-upgrade' do
#   code "apt-get dist-upgrade -y"
# end

package "python-openstackclient" do
  action [ :install ]
end
