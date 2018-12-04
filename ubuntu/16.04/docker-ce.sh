#!/usr/bin/env bash

# This script will install docker-ce.
# https://docs.docker.com/engine/installation/linux/docker-ce/ubuntu/#install-docker-ce
# To execute this script run the following as root
# bash <(curl http://installs.truemark.io/ubuntu/16.04/docker-ce.sh)

set -uex

echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.d/docker.conf
echo fs.inotify.max_user_instances=16384 | sudo tee -a /etc/sysctl.d/docker.conf
echo fs.file-max=5000000 | sudo tee -a /etc/sysctl.d/docker.conf
sudo sysctl -p 
echo "* - nofile 500000" | sudo tee -a /etc/security/limits.d/docker.conf
echo "* - nproc 500000" | sudo tee -a /etc/security/limits.d/salt.conf

apt-get update

apt-get install -y \
  apt-transport-https \
  ca-certificates \
  curl \
  software-properties-common \
  xfsprogs

# We need to partition /dev/sdb for docker before we begin
# https://superuser.com/questions/332252/creating-and-formating-a-partition-using-a-bash-script
# To create the partitions programatically (rather than manually)
# we're going to simulate the manual input to fdisk
# The sed script strips off all the comments so that we can 
# document what we're doing in-line with the actual commands
# Note that a blank line (commented as "defualt" will send a empty
# line terminated with a newline to take the fdisk default.
# >100 GB 2nd Virtual HDD is required for this script to work
sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF | fdisk /dev/sdb
  o # clear the in memory partition table
  n # new partition
  p # primary partition
  1 # partition number 1
    # default - start at beginning of disk 
    # default - end at end of disk
  t # partition type
  8e # partition type Linux LVM
  p # print the in-memory partition table
  w # write the partition table
  q # and we're done
EOF
pvcreate /dev/sdb1
vgcreate vg2 /dev/sdb1
lvcreate -L50G -ndocker vg2
mkfs.xfs -n ftype=1 -f /dev/vg2/docker
mkdir -p /var/lib/docker
echo "/dev/mapper/vg2-docker /var/lib/docker xfs defaults 0 2" >> /etc/fstab
mount -a

timedatectl set-timezone 'UTC'

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -

apt-key fingerprint 0EBFCD88

add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

apt-get update

apt-get install -y docker-ce apparmor

apt-mark hold docker-ce

## Setup the dummy interface used for host services
echo "dummy" >> /etc/modules

cat >> /etc/network/interfaces <<EOL

auto dummy0
iface dummy0 inet static
address 169.254.1.1
netmask 255.255.255.255
EOL

modprobe dummy

## Setup default docker settings
cat >> /etc/docker/daemon.json <<EOF
{
  "log-driver": "journald"
}
EOF

systemctl restart docker
