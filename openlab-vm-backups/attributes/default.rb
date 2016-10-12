#Packages to install
default['openlab-vm-backups']['packages'] = %w{rsync rsnapshot nfs-utils nfs-utils-lib}

#Mount points
default['openlab-vm-backups']['mount-point']['backup'] = "/mnt/vms"
default['openlab-vm-backups']['mount']['vms'] = "openlab.cs.tamu.edu:/vms"

