#!/usr/bin/env bash

###############################################################################
# This script applies some hardening customizations
#
# To execute this script run the following as root
# bash <(curl http://download.truemark.io/installs/ubuntu/18.04/hardening.sh) 2>&1 | tee -a /var/log/tminstall.log
###############################################################################

if [[ "$(whoami)" != "root" ]]; then
	echo "Script must be run as root"
	exit 1
fi

echo "###############################################################################"
echo "Executing cust.sh"
echo "###############################################################################"
set -uex
export DEBIAN_FRONTEND=noninteractive

#################################
## Establish Password Policies ##
#################################

# Install requisite packages
apt-get update && apt-get install apparmor ufw cracklib-runtime libpam-pwquality -y

# Set password policies
# These changes allow the system to remember the last 5 passwords and prevent them from being reused
sed -i "s/try_first_pass sha512/try_first_pass sha512 remember=5/" /etc/pam.d/common-password

# This section sets will require all 4 character type classes (Upper/Lower/Digital/Other)
sed -i "s/# dcredit = 0/dcredit = -1/" /etc/security/pwquality.conf
sed -i "s/# ucredit = 0/ucredit = -1/" /etc/security/pwquality.conf
sed -i "s/# lcredit = 0/lcredit = -1/" /etc/security/pwquality.conf
sed -i "s/# ocredit = 0/ocredit = -1/" /etc/security/pwquality.conf

#########################
## Harden Shell Access ##
#########################

# Add Login Notification
echo "###############################################################
# Be aware all connections are monitored and recorded!        #
# Disconnect IMMEDIATELY if you are not an authorized user!   #
###############################################################" > /etc/motd

# Set SSH Protocol to v2
echo "
# Use SSH Protocol 2 Version
Protocol 2" >> /etc/ssh/sshd_config

# Set session timeout to 15 mins
sed -i "s/#ClientAliveInterval 0/ClientAliveInterval 900/" /etc/ssh/sshd_config
sed -i "s/#ClientAliveCountMax 3/ClientAliveCountMax 0/" /etc/ssh/sshd_config

# Disable root login via SSH
sed -i "s/#PermitRootLogin prohibit-password/#PermitRootLogin no/" /etc/ssh/sshd_config

# Apply changes to SSH service
service sshd restart

##########################################
## Updating network and enable firewall ##
##########################################

# Disable IPV6
cat > /etc/sysctl.d/90-disableipv6.conf <<EOF
# Disabling IPV6
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1
EOF

# Enable default apparmor
systemctl start apparmor
systemctl enable apparmor

# Install and setup default firewall settings
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh
echo "y" | ufw enable
ufw status verbose
