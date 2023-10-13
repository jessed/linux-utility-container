#! /usr/bin/bash

# Export common env variables
export UID=0
export GID=995
export ROOT=/etc/tinydns/root

# source the addr() function
source ~/.bash_functions

# identify addresses
addrs=$(addr | awk '{print $2}' | cut -d/ -f1)

# Remove any existing data file (if present)
test -f /etc/tinydns/root/data && rm /etc/tinydns/root/data

# Update the /etc/tinydns/root/data file with all of the addresses
count=1
for a in $addrs; do
  echo ".f5test.net:$a:server${count}.f5test.net:259200" >> /etc/tinydns/root/data
  ((count++))
done

# Add actual records to the data file
echo >> /etc/tinydns/root/data
cat /etc/tinydns/root/initial.data >> /etc/tinydns/root/data

# Build the data.cbd
cd /etc/tinydns/root
/usr/sbin/tinydns-data

# Start one tinydns process for each IP address
for a in $addrs; do
  export IP=$a
  /usr/sbin/tinydns >/dev/null 2>&1 &
done
