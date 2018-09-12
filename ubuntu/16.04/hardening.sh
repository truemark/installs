## TrueMark Ubuntu 16 Hardening
## Must be ran as root

#!/usr/bin/env bash

# To execute this script run the following as root
set -uex

##########################################################
## Configure syslog to forward to central syslog server ##
##########################################################

#the below is commented out, as it will change per client/environment. 
#echo "*.*;auth,authpriv.none @<target-server>:514" > /etc/rsyslog.d/51-custom.conf

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
auth        sufficient   pam_unix.so likeauth

# Remember the last 5 passwords and prevent them from being reused
password   sufficient    pam_pwhistory.so remember=5 use_authtok

# This section sets retries to 3, minimum length to 10 & that all 4 type classes (Upper/Lower/Digital/Other) are required.
password        requisite       pam_pwquality.so minlen=8 dcredit=-1 ucredit=-1 lcredit=-1 ocredit=-1" >> /etc/pam.d/common-password

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
