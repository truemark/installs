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

apt-get install -y docker-ce

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
