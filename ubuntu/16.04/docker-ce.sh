#!/usr/bin/env bash

# This script will install docker-ce.
# https://docs.docker.com/engine/installation/linux/docker-ce/ubuntu/#install-docker-ce
# To execute this script run the following as root
# bash <(curl http://installs.truemark.io/ubuntu/16.04/docker-ce.sh)

set -uex

apt-get update

apt-get install -y \
  apt-transport-https \
  ca-certificates \
  curl \
  software-properties-common

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

## Setup dnsmasq and dnsutils
apt-get install -y dnsutils dnsmasq

# This will prevent overwriting /etc/resolv.conf
echo "DNSMASQ_EXCEPT=lo" >> /etc/default/dnsmasq

# This tells dnsmasq not to use resolv.conf and to forward *.consul requests to the local consul daemon
cat > /etc/dnsmasq.d/local.conf <<EOF
no-resolv
server=/consul/169.254.1.1#8600
EOF

# Put the upstream servers in the dnsmasq config
cat /etc/resolv.conf | grep nameserver | sed 's/nameserver /server=/g' >> /etc/dnsmasq.d/local.conf

# Replace the dns-nameservers in the interfaces file
sed -i 's/dns-nameservers.*/dns-nameservers 169.254.1.1/g' /etc/network/interfaces

# Replace the current resolv.conf until a reboot occurs
sed -i 's/nameserver.*/nameserver 169.154.1.1/g' /etc/resolv.conf

# Restart services
systemctl restart dnsmasq
resolvconf -u
systemctl restart docker
