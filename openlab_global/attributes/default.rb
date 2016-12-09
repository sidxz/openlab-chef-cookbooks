default['openlab-identity']['openstack-cli']['OS_USERNAME'] = 'admin'
default['openlab-identity']['openstack-cli']['OS_PASSWORD'] = 'WatchDogs2'
default['openlab-identity']['openstack-cli']['OS_PROJECT_NAME'] = 'admin'
default['openlab-identity']['openstack-cli']['OS_USER_DOMAIN_NAME'] = 'default'
default['openlab-identity']['openstack-cli']['OS_PROJECT_DOMAIN_NAME'] = 'default'
default['openlab-identity']['openstack-cli']['OS_AUTH_URL'] = 'http://controller:35357/v3'
default['openlab-identity']['openstack-cli']['OS_IDENTITY_API_VERSION'] = '3'




default['openlab-global']['admin-credentials'] = "--os-username=#{default['openlab-identity']['openstack-cli']['OS_USERNAME']} --os-password=#{default['openlab-identity']['openstack-cli']['OS_PASSWORD']} "
default['openlab-global']['project-params'] = "--os-project-name=#{default['openlab-identity']['openstack-cli']['OS_PROJECT_NAME']} --os-user-domain-name=#{default['openlab-identity']['openstack-cli']['OS_USER_DOMAIN_NAME']} --os-project-domain-name=#{default['openlab-identity']['openstack-cli']['OS_PROJECT_DOMAIN_NAME']} --os-auth-url=\"#{default['openlab-identity']['openstack-cli']['OS_AUTH_URL']}\" --os-identity-api-version=#{default['openlab-identity']['openstack-cli']['OS_IDENTITY_API_VERSION']}"

default['com_rabbitmq']['rabbit_pass'] = 'WatchDogs2'
