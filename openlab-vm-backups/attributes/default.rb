#Packages to install
default['openlab-vm-backups']['packages'] = %w{epel-release rsync rsnapshot nfs-utils }

#Mount points
default['openlab-vm-backups']['mount-point']['backup'] = "/mnt/vms"
default['openlab-vm-backups']['mount']['vms'] = "openlab.cs.tamu.edu:/vms"

#Dirs
default['openlab-vm-backup']['dirs'] = %w{controller storage network}

#SSH Known host
default['openlab-vm-backup']['ssh-finger-print'] = "openlab.cs.tamu.edu ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBFQc0nUTW5wwCRhIGZf1/cP+IM8zQ9PLTPumzkGD08FXpMq0p764sR8DW+ZEW0bvi9HEqsR2Z8v5iyTn76BVOu8="
