#!/usr/bin/env bash

# To execute this script run the following as root
# bash <(curl http://installs.truemark.io/ubuntu/16.04/docker-dnsmasq.sh)

set -uex

## Install dnsmasq and dnsutils
apt-get install -y dnsutils dnsmasq

# Stop dnsmasq so the next configurations work
systemctl stop dnsmasq

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
sed -i 's/nameserver.*/nameserver 169.254.1.1/g' /etc/resolv.conf

# Restart services
systemctl start dnsmasq
resolvconf -u
systemctl restart docker
