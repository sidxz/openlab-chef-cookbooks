default['openlab-identity']['install']['keystone-dp-pass'] = "WatchDogs2"

default['openlab-identity']['openstack-cli']['OS_USERNAME'] = 'admin'
default['openlab-identity']['openstack-cli']['OS_PASSWORD'] = 'WatchDogs2'
default['openlab-identity']['openstack-cli']['OS_PROJECT_NAME'] = 'admin'
default['openlab-identity']['openstack-cli']['OS_USER_DOMAIN_NAME'] = 'default'
default['openlab-identity']['openstack-cli']['OS_PROJECT_DOMAIN_NAME'] = 'default'
default['openlab-identity']['openstack-cli']['OS_AUTH_URL'] = 'http://openlab-controller:35357/v3'
default['openlab-identity']['openstack-cli']['OS_IDENTITY_API_VERSION'] = '3'


# Install sample projects and users
default['openlab-identity']['install-samples'] = true
