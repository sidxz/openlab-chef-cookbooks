#TimeZone
default['openlab-utils']['time-zone']= "America/Chicago"

#NTP Servers
default['ntp']['servers'] = %w(ntp1.tamu.edu ntp2.tamu.edu ntp3.tamu.edu)

#Memcached Ip
default['openlab-utils']['memcached']['bind-ip'] = "128.194.142.141"