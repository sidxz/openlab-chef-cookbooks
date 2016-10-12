# coe-lwrp-ssh
LWRPs in Chef make use of a special Ruby DSL to allow Chef users to implement their
own resources and providers. The DSL used by LWRPs abstracts away much of the
underlying code needed to create resources and providers and integrate them with
Chef ’s class structure.

*coe-lwrp-ssh* contains LWRPs related to ssh modules
##1. User
This adds public and private keys and sets up known host so that ssh works bypassing the 'accepting finger print' prompt.
###Sample Usage
```
coe_lwrp_ssh_user "git" do
	cookbook_name 'lwrp-test' 
	private_key 'private.key'
	public_key 'public.key'
	known_host node['coe']['cookbookname']['knownhost']
	user "git"	
	action :add
end
```

**cookbook_name** is the name of the cookbook in which this lwrp will be used

**private_key** is a cookbook file placed in your cookbook

**public_key** is a cookbook file placed in your cookbook

**known_host**_(string)_ is the finger print (Obtain this by connecting once to the server and then extract it from known hosts)

**user** user to connect with

**action :add** (default) to add ssh user 

**action :remove**, to remove ssh user
