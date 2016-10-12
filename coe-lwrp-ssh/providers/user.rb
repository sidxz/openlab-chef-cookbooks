#Base Provider
#Notifications are impacted here.  
#if you do delayed notifications, they will be performed at the end of the resource run
#and not at the end of the chef run.  
#You do want to use this as it also affects internal resource notifications.
#Summary : ALWAYS USE THIS
use_inline_resources

def whyrun_supported?
  true
end

#Override load_current_resource
def load_current_resource
  #Instantiate and populate @current resource object
  @current_resource = Chef::Resource::CoeLwrpSshUser.new(new_resource.name)
  @current_resource.public_key(new_resource.public_key)
  @current_resource.private_key(new_resource.private_key)
  @current_resource.known_host(new_resource.known_host)
  @current_resource.server(new_resource.server)
  @current_resource.user(new_resource.user)
  @current_resource.cookbook_name(new_resource.cookbook_name)
end

action :add do

  if !@current_resource.exists
    #Converge our node
    converge_by("Config SSH: Converging |+ add |.....") do
      #call the add function
      resp = add
      #We set our updated flag based on the resource we utilized.
      @new_resource.updated_by_last_action(true)
    end

  else
    Chef::Log.error "SSH User is allready added. Not Creating."
  end
end


action :remove do
  if !@current_resource.exists
    #Converge our node
    converge_by("Config SSH: Converging | -REMOVE |.....") do
      #call the remove function
      resp = remove
      #We set our updated flag based on the resource we utilized.
      @new_resource.updated_by_last_action(true)
    end

  else
    Chef::Log.error "SSH is either removed or has not been setup. Skipping."
  end

end

#############################
#### METHODS ################

def add
  #Creare Directory to put priv/pub key
  action_update = true
  directory "/root/.ssh/#{current_resource.name}" do
	  owner 'root'
	  group 'root'
	  mode '0755'
	  recursive true
	  action :create
  end

  #Private Key
  cookbook_file "/root/.ssh/#{current_resource.name}/id_rsa" do 
	  source "#{current_resource.private_key}"
	  cookbook "#{current_resource.cookbook_name}"
	  mode '0400'
	  owner 'root'
	  group 'root'
	end
 
  #Public Key
  cookbook_file "/root/.ssh/#{current_resource.name}/id_rsa.pub" do 
    source "#{current_resource.public_key}"
    cookbook "#{current_resource.cookbook_name}"
    mode '0400'
    owner 'root'
    group 'root'
  end

  #Known Host
  if (!::File.exist?('/root/.ssh/known_hosts') || ::File.open('/root/.ssh/known_hosts').grep(/#{current_resource.server}/).empty?)
    ruby_block 'add_new_known_host' do
      block do
        system "echo #{current_resource.known_host} | cat >> /root/.ssh/known_hosts"
      end
    end
    Chef::Log.warn "+ Added new host #{current_resource.known_host} "  
  elsif ::File.open('/root/.ssh/known_hosts').grep(/#{current_resource.known_host}/).empty?
    ruby_block 'change_known_host' do
      block do
        system "sed -i -e '/#{current_resource.server}/d' /root/.ssh/known_hosts"
        system "echo #{current_resource.known_host} | cat >> /root/.ssh/known_hosts"
      end
    end
    Chef::Log.warn "** + Updated new host #{current_resource.known_host} "
  else
    Chef::Log.warn "+ known_host (up to date) "
  end

  #SSH Config

  if (!::File.exist?('/root/.ssh/config') || ::File.open('/root/.ssh/config').grep(/#{current_resource.server}/).empty?)
      ruby_block 'modify_ssh_config' do
        block do
          system "echo host #{current_resource.server} | cat >> /root/.ssh/config"
          system "echo -e  \"\tHostName #{current_resource.server}\" | cat >> /root/.ssh/config"
          system "echo -e  \"\tIdentityFile ~/.ssh/#{current_resource.name}/id_rsa\" | cat >> /root/.ssh/config"
          system "echo -e  \"\tUser #{current_resource.user} \"| cat >> /root/.ssh/config"
        end
      end
    Chef::Log.warn "* + Created /root/.ssh/config "
    Chef::Log.warn "+ #{current_resource.server} \n\t HostName #{current_resource.server} \n\t IdentityFile ~/.ssh/#{current_resource.name}/id_rsa \n\tUser #{current_resource.user}   "
    else
    Chef::Log.warn "+ /root/.ssh/config (up to date) "
  end
end

def remove
  #Private Key
  cookbook_file "/root/.ssh/#{current_resource.name}/id_rsa" do 
	  source "#{current_resource.private_key}"
	  action :delete
  end
 
  #Public Key
  cookbook_file "/root/.ssh/#{current_resource.name}/id_rsa.pub" do 
    source "#{current_resource.public_key}"
    action :delete
  end

   #SSH Config
  if (::File.exist?('/root/.ssh/config') && ::File.open('/root/.ssh/config').grep(/#{current_resource.server}/))
      ruby_block 'remove_ssh_config' do
        block do
          system "sed -i -e '/#{current_resource.server}/,+3d' /root/.ssh/config"
        end
      end
      Chef::Log.warn "* - /root/.ssh/config Deleted #{current_resource.server}"
  end

  #Known Host
  if (::File.exist?('/root/.ssh/known_hosts') && ::File.open('/root/.ssh/known_hosts').grep(/#{current_resource.server}/))
    ruby_block 'remove_known_host' do
      block do
        system "sed -i -e '/#{current_resource.server}/d' /root/.ssh/known_hosts"
      end
    end
    Chef::Log.warn "* - /root/.ssh/known_hosts Deleted #{current_resource.server}" 
  end

end

