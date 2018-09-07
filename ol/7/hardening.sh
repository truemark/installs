## TrueMark Oracle Linux 7 Hardening
## Must be ran as root

#!/usr/bin/env bash

##########################################################
## Configure syslog to forward to central syslog server ##
##########################################################

#echo "*.*;auth,authpriv.none @Target-Log-Server:514" > /etc/rsyslog.d/51-custom.conf

##########################
## Apply Latest Patches ##
##########################

yum update && yum upgrade -y

#################################
## Establish Password Policies ##
#################################

# Set password policies
authconfig --passminlen=8 --passminclass=4 --update # Require min of 8 characters and require all 4 type classes Upper/Lower/Digital/Other

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

#####################################
## Updating network and ntp config ##
#####################################

# Disable IPV6
echo "
# Disabling IPV6
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1" >> /etc/sysctl.conf

sysctl -p

# Point ntp to the YL time server
#echo "server time.yleo.us" >> /etc/ntp.conf

# Enable default firewall
systemctl start firewalld
systemctl enable firewalld

# Add defenitions for services we need to allow
#echo "<?xml version=\"1.0\" encoding=\"utf-8\"?>
#<service>
#  <short>actifioudsagent</short>
#  <description>Actifio UDS Agent</description>
#  <port protocol=\"tcp\" port=\"5106\"/>
#  <port protocol=\"udp\" port=\"5106\"/>
#  <port protocol=\"tcp\" port=\"56789\"/>
#  <port protocol=\"udp\" port=\"56789\"/>
#</service>" > /etc/firewalld/services/actifio-uds-agent.xml

echo "<?xml version=\"1.0\" encoding=\"utf-8\"?>
<service>
  <short>oraclelistener</short>
  <description>Oracle Listener</description>
  <port protocol=\"tcp\" port=\"1521\"/>
  <port protocol=\"udp\" port=\"1521\"/>
</service>" > /etc/firewalld/services/oracle-listener.xml

echo "<?xml version=\"1.0\" encoding=\"utf-8\"?>
<service>
  <short>oem</short>
  <description>Oracle OEM</description>
  <port protocol=\"tcp\" port=\"3872\"/>
  <port protocol=\"udp\" port=\"3872\"/>
</service>" > /etc/firewalld/services/oracle-oem.xml

# Reload to allow access to new 
firewall-cmd --reload

# Enabling the new services
#firewall-cmd --zone=public --permanent --add-service=actifio-uds-agent

#The next two should only be enabled on db servers as needed. 
#firewall-cmd --zone=public --permanent --add-service=oracle-oem
#firewall-cmd --zone=public --permanent --add-service=oracle-listener
