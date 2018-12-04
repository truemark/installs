#!/usr/bin/env bash

###############################################################################
# This script prepares the OS for cloning.
# WARNING: This script will shutdown the OS at the end of the script.
#
# To execute this script run the following as root
# bash <(curl http://download.truemark.io/installs/ubuntu/18.04/cloneprep.sh) 2>&1 | tee -a /var/log/tminstall.log
###############################################################################

if [[ "$(whoami)" != "root" ]]; then
	echo "Script must be run as root"
	exit 1
fi

echo "###############################################################################"
echo "Executing cloneprep.sh"
echo "###############################################################################"
set -x
set -e

# Clear out the systemd machine-id. It will be re-generated on boot.
if [ -f /etc/machine-id ]; then
	echo "truemark" > /etc/machine-id
fi

# Remove SSH Host keys.
rm -f /etc/ssh/*_key*

# Make SSH Host keys re-generate on boot.
echo '#!/usr/bin/env bash

ssh-keygen -A
rm -f /etc/init.d/hostkeys' > /etc/init.d/hostkeys
chmod +x /etc/init.d/hostkeys

# Clear out logs
systemctl stop syslog.service
rm -f /var/log/*.gz
rm -f /var/log/*[0-9].log
if [ -f /var/log/syslog ]; then
	cat /dev/null > /var/log/syslog
fi
if [ -f /var/log/messages ]; then
	cat /dev/null > /var/log/messages
fi
rm -rf /var/log/journal/*
if [ -f /var/log/authlog ]; then
	cat /dev/null > /var/log/auth.log
fi

# Shutdown the OS
shutdown -h now
