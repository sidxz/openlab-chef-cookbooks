#
# Cookbook Name:: openlab_identity
# Recipe:: samples
#
# Copyright (c) 2016 The Authors, All Rights Reserved.


if(node['openlab-identity']['install-samples'] && !File.exist?("/root/.chefvars
/openlab_identity-samples-installed.bool"))

#Set Identity Variable
# We ar not using environment variables so we need to pass variables in cli
#Ref: https://wiki.openstack.org/wiki/OpenStackClient/Authentication
# Pick one of OS_PROJECT_NAME or OS_PROJECT_ID
# OS_PROJECT_ID=<project-id>                 # --os-project-id
# OS_PROJECT_NAME=<project-name>             # --os-project-name
# OS_USERNAME=<username>                     # --os-username
# OS_PASSWORD=<password>                     # --os-password
# OS_AUTH_URL=<identity-api-endpoint>        # --os-auth-url

credentials = node['openlab-global']['admin-credentials']
projectParams = node['openlab-global']['project-params']
#The Identity service provides authentication services for each OpenStack
#service. The authentication service uses a combination of domains, projects,
#users, and roles.

#Create the service project:
execute "project-create-admin" do
  command <<-EOH
  openstack project create --domain default --description "Service Project" #{credentials} #{projectParams} service
  EOH
  live_stream true
end


#Regular (non-admin) tasks should use an unprivileged project and user
execute "project-create-nonadmin" do
  command <<-EOH
  openstack project create --domain default --description "Demo Project" #{credentials} #{projectParams} demo
  EOH
  live_stream true
end

# Create the demo user
execute "user-create-nonadmin" do
  command <<-EOH
  openstack user create --domain default --description "Demo Project" --password=demo #{credentials} #{projectParams} demo
  EOH
  live_stream true
end

# Create the user role:
execute "role-create-user" do
  command <<-EOH
  openstack role create #{credentials} #{projectParams} user
  EOH
  live_stream true
end

#Add the user role to the demo project and user:
execute "add-user-to-demo-project" do
  command <<-EOH
  openstack role add --project demo --user demo #{credentials} #{projectParams} user
  EOH
  live_stream true
end

# Touch file to prevent multiple run
execute "lock-samples-recipe" do
  command <<-EOH
  touch /root/.chefvars/openlab_identity-samples-installed.bool
  EOH
  live_stream true
end

end


