## TrueMark Ubuntu 18 Hardening
## Must be ran as root

#!/usr/bin/env bash

# To execute this script run the following as root
# bash <(curl http://installs.truemark.io/ubuntu/18.04/truemark.sh)
set -uex

##########################################################
## Configure syslog to forward to central syslog server ##
##########################################################
# THIS SECTION IS COMMENTED OUT DUE TO THE FACT THAT IT WILL DIFFER PER CLIENT/ENVIRONMENT.
# THIS SECTION SHOULD BE ADDED TO THE CLIENT'S SETUP SCRIPT OR HARDENING SCRIPT IF THERE IS ONE.

#echo "*.*;auth,authpriv.none @TARGET-SYSLOG-SERVER:514" > /etc/rsyslog.d/51-custom.conf

##########################
## Apply Latest Patches ##
##########################

export DEBIAN_FRONTEND=noninteractive
apt-get update && apt-get upgrade -y

#################################
## Establish Password Policies ##
#################################

# Set password policies
echo "
# This section has been added as part of the hardening process.
# Prevent blank passwords
auth        sufficient    so likeauth nullok

# Remember the last 5 passwords and prevent them from being reused
password   sufficient    pam_unix.so nullok use_authtok md5 shadow remember=5" >> /etc/pam.d/system-auth

echo "
# This section sets retries to 3, minimum length to 10 & that all 4 type classes (Upper/Lower/Digital/Other) are required. 
password requisite pam_cracklib.so retry=3 minlen=10 ucredit=-1 lcredit=-1 dcredit=-1  ocredit=-1"

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
echo "
ClientAliveInterval 15m      # 15 minutes" >> /etc/ssh/sshd_config

# Disable root login via SSH
sed -i "s/#PermitRootLogin yes/PermitRootLogin no/" /etc/ssh/sshd_config

# Require users to use ssh keys
sed -i "s/#PasswordAuthentication yes/PasswordAuthentication no/" /etc/ssh/sshd_config

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

# Enable default firewall

systemctl start apparmor
systemctl enable apparmor
