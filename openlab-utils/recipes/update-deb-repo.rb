#
# Cookbook Name:: openlab-utils
# Recipe:: update-deb-repo
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

bash 'apt-update' do
  code "sudo apt-get update"
end
