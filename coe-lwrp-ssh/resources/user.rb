actions :add, :remove
default_action :add

attribute :name, :kind_of => String, :name_attribute => true
attribute :server, :kind_of => String , :default => 'github.tamu.edu'
attribute :private_key, :kind_of => String, :required => true
attribute :public_key, :kind_of => String, :required => true
attribute :known_host, :kind_of => String, :required => true
attribute :user, :kind_of => String, :required => true
attribute :cookbook_name, :kind_of => String


attr_accessor :exists
