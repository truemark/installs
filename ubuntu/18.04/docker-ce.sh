#!/usr/bin/env bash

###############################################################################
# This script will install docker-ce.
# https://docs.docker.com/engine/installation/linux/docker-ce/ubuntu/#install-docker-ce
# WARNING: This script expects a 2nd unpartitioned drive at /dev/sdb
#
# To execute this script run the following as root
# bash <(curl http://download.truemark.io/installs/ubuntu/18.04/docker-ce.sh) 2>&1 | tee -a /var/log/tminstall.log
###############################################################################

if [[ "$(whoami)" != "root" ]]; then
	echo "Script must be run as root"
	exit 1
fi

echo "###############################################################################"
echo "Executing docker-ce.sh"
echo "###############################################################################"
set -x

cat > /etc/sysctl.d/95-docker.conf <<EOF
fs.inotify.max_user_watches=524288
fs.inotify.max_user_instances=16384
fs.file-max=5000000
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1
EOF

sysctl -p

cat > /etc/security/limits.d/95-docker.conf <<EOF
* - nofile 500000
* - nproc 500000
EOF

apt-get update && apt-get install xfsprogs -y

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
lvcreate -L100G -ndocker vg2
mkfs.xfs -n ftype=1 -f /dev/vg2/docker
mkdir -p /var/lib/docker
echo "/dev/mapper/vg2-docker /var/lib/docker xfs defaults 0 2" >> /etc/fstab
mount -a

apt-get update && apt-get install -y \
	gpg-agent gnupg apt-transport-https ca-certificates \
	curl software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -

apt-key fingerprint 0EBFCD88

add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

apt-get update &&  apt-get install -y docker-ce apparmor

apt-mark hold docker-ce

## Setup default docker settings for logging and DNS
cat >> /etc/docker/daemon.json <<EOF
{
  "dns": ["169.254.1.1"],
  "log-driver": "journald"
}
EOF

## Setup the dummy interface used for host services

cat > /etc/systemd/network/10-dummy0.netdev <<EOF
[NetDev]
Name=dummy0
Kind=dummy
EOF

cat > /etc/systemd/network/20-dummy0.network <<EOF
[Match]
Name=dummy0

[Network]
Address=169.254.1.1/32
EOF

echo "dummy" >> /etc/modules
modprobe dummy
systemctl restart systemd-networkd

## Setup dnsmasq
apt-get install -y dnsutils dnsmasq
systemctl stop dnsmasq

# This tells dnsmasq not to use resolv.conf and to forward *.consul requests to the local consul daemon
cat > /etc/dnsmasq.d/local.conf <<EOF
server=/consul/169.254.1.1#8600
EOF

# This will prevent overwriting /etc/resolv.conf
cat >> /etc/default/dnsmasq <<EOF
DNSMASQ_EXCEPT=lo
DNSMASQ_INTERFACE=dummy0
DNSMASQ_OPTS="-z"
EOF

systemctl enable dnsmasq
systemctl start dnsmasq

# Restart Docker ... a reboot is recommended
systemctl restart docker
