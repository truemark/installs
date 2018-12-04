#!/usr/bin/env bash

###############################################################################
# This script sets up a number of VMware specific settings
# This script is safe to re-run on a system where it's been run before.
# # To execute this script run the following as root
# bash <(curl http://download.truemark.io/installs/ubuntu/18.04/vmware.sh) > /var/log/tminstall.log 2>&1
###############################################################################

if [[ "$(whoami)" != "root" ]]; then
	echo "Script must be run as root"
	exit 1
fi

echo "###############################################################################"
echo "Executing vmware.sh"
echo "###############################################################################"
set -x

apt-get update && apt-get install open-vm-tools -y

echo '[Unit]
Description=Creates SSH host keys if missing

[Service]
Type=oneshot
ExecStart=/bin/bash -c "if [ -f /usr/sbin/sshd ]; then if ls /etc/ssh/*_key* > /dev/null 2>&1; then :; else ssh-keygen -A; fi; fi"

[Install]
WantedBy=multi-user.target
' > /etc/systemd/system/sshkeys.service

echo $'[Unit]
Description=Sets VMware NIC buffer size
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=/bin/bash -c \'for i in $(netstat -i | sed "s/ .*//g" | tail -n+3); do out=$(ethtool -i $i 2>&1 | grep driver); if [[ $out == *"vmxnet3"* ]] || [[ $out == *"e1000"* ]]; then echo "Running: ethtool -G $i rx 4096 tx 4096"; ethtool -G $i rx 4096 tx 4096; fi done\'

[Install]
WantedBy=multi-user.target
' > /etc/systemd/system/vmnicbuff.service

systemctl daemon-reload
systemctl enable sshkeys.service
systemctl enable vmnicbuff.service
