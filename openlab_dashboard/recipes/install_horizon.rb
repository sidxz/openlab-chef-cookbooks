#
# Cookbook Name:: openlab_dashboard
# Recipe:: install_horizon
#
# Copyright (c) 2016 The Authors, All Rights Reserved.


#Install Horizon
%w(openstack-dashboard).each do |pkg|
  package pkg do
    action [ :install ]
  end
end

