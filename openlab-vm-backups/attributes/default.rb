#Packages to install
default['openlab-vm-backups']['packages'] = %w{epel-release rsync rsnapshot nfs-utils }

#Mount points
default['openlab-vm-backups']['mount-point']['backup'] = "/mnt/vms"
default['openlab-vm-backups']['mount']['vms'] = "openlab.cs.tamu.edu:/vms"

