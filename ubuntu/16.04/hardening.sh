## TrueMark Ubuntu 16 Hardening
## Must be ran as root

#!/usr/bin/env bash

# To execute this script run the following as root
set -uex

##########################################################
## Configure syslog to forward to central syslog server ##
##########################################################

#echo "*.*;auth,authpriv.none @<target-server>:514" > /etc/rsyslog.d/51-custom.conf   #Commented out, as it will change per client/environment.

##########################
## Apply Latest Patches ##
##########################

export DEBIAN_FRONTEND=noninteractive
apt-get update && apt-get upgrade -y

#################################
## Establish Password Policies ##
#################################

# Install requisite packages
apt-get install cracklib-runtime libpam-pwquality -y

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

# Set session timeout to 15 mins
echo "
ClientAliveInterval 900      # 15 minutes
ClientAliveCountMax 0" >> /etc/ssh/sshd_config

# Disable root login via SSH
sed -i "s/#PermitRootLogin prohibit-password/PermitRootLogin no/" /etc/ssh/sshd_config

# Require users to use ssh keys
sed -i "s/#PasswordAuthentication yes/PasswordAuthentication no/" /etc/ssh/sshd_config

# Set Auth Log level to verbose to capture ssh key fingerprints 
sed -i "s/#LogLevel INFO/LogLevel VERBOSE/" /etc/ssh/sshd_config

# Apply changes to SSH service
service sshd restart

##########################################
## Updating network and enable firewall ##
##########################################

# Disable IPV6
echo "
# Disabling IPV6
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1" >> /etc/sysctl.d/99-sysctl.conf

echo "#!/bin/bash
# /etc/rc.local
# Load kernel variables from /etc/sysctl.d
/etc/init.d/procps restart
exit 0" > /etc/rc.local

chmod 755 /etc/rc.local

# Enable default apparmor

systemctl start apparmor
systemctl enable apparmor

# Install and setup default firewall settings
apt-get install ufw -y
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh
echo "y" | ufw enable
ufw status verbose
