## TrueMark Oracle Linux 7 base setup
## Must be ran as root

#################################################
## Setup server to pull updates via the proxy ##
#################################################

sed -i "s/enableProxy=0/enableProxy=1/" /etc/sysconfig/rhn/up2date
sed -i "s/httpProxy=/httpProxy=http://<target-server>:3128/" /etc/sysconfig/rhn/up2date

#################################################
## Prepare For Install NewRelic Infrastructure ##
#################################################

# Create the agent’s yum repository
sudo curl -o /etc/yum.repos.d/newrelic-infra.repo https://download.newrelic.com/infrastructure_agent/linux/yum/el/7/x86_64/newrelic-infra.repo

# Update your yum cache
sudo yum -q makecache -y --disablerepo='*' --enablerepo='newrelic-infra'

# Adding EPEL and Haveged

wget http://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
sudo rpm -Uvh epel-release-latest-7.noarch.rpm
sudo yum update -y
sudo yum install epel-release haveged -y

# Run the installation script, this portion of the script
#   should only be ran on a new host with the host name up dated. 

# sudo yum install newrelic-infra -y

################################
## Install Actifio Connector  ##
################################

# Download and install the latest Actifio Connector
#curl --remote-name http://<target-host>/connector-Linux-latestversion.rpm
#rpm -ivh connector-Linux-latestversion.rpm

##########################
## Configure Admin User ##
##########################

# Add the Admin user
adduser user

# Add user as a wheel (sudoer) group
usermod -aG wheel user

# Allow user to sudo without a password
echo "
#Admin user password not required to sudo
user    ALL=(ALL:ALL) NOPASSWD:ALL" >> /etc/sudoers.d/admins

# Have sudoers include sudoers.d
sed -i "s/#includedir/includedir/" /etc/sudoer.d  #includedir /etc/sudoers.d

# Set passwords for Root and Admin user
echo "root:truemark" | chpasswd
echo "user:truemark" | chpasswd

########################
## Setup Shell Access ##
########################

# Add SSH Keys for Admin Users
mkdir /home/user/.ssh
chmod 700 /home/user/.ssh
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC1fkhdIXBC7F5nwloCMK4nAu5HV9L8aLYlZyBVr1+yr3Bbw1RatnN9Y+cIo9FtLc9NDBLrP7w39A5+4rmmPs/ZgfAhvq4sozAwAdTfkBqLgMDN932CKmI8RB99HDVq7vcCURnGELkOrnlgab1g8Pl4vjRSIytThPpOxM6papS+erGpq4cSprbIG1z1lBTIgJszOWxo0UaM0TGoAPQhGBXg3jvHZ9yCEBe3j2dq2fgP0Lo0XeGAO8OmePAw6oMc+SaY9kYChxeFr+UjZX4C9L0vjGdJHPF6wBuAMwLOxsxLpuBAGbz/IowSnc/tGYItOkQl94Jb04x8BDXNU/w5lLTN Kyle Stephenson
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDl+CZNejqgctLoRkq7VQoQ4ozi/9Em4j7OZwcaBZhl9SZfYoVfoS+GNDJZAnkKJUjMetCtnJtbqPAELkg64HSgxm0CMR4h/QBKyYwp7u6kq0iDQOpJN/9RKndvIgDGT+uJAcxs1NBCHJ8LubJw+yF3zjfCgqCRzEm6jjnJa1rGSRjyqwG7BofIxoqKIgM7tszNkz+pzeJIoo2Oz0+jQ9gBrWtW6Ncd0Clswu1xk8O+jLSf5bt7Ig+5uKvrLzFsZ/6JD9GFu9d5mYP3NMOhXzN++VuRn7R5TMG/n0Y6LysLPG2eImUIU1PAmpH6CBRITthHtMr3+e9bU2N6ZGGtsExj Erik Jensen
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDqQtm77g8sZ1pgJKdBxYX2wtva3cQ0f2Lmm27Gi4T6WDWV+KG8YGj6ukVDdGNykVlcVEVLsir78whUxmjkrwf23w0m/uGhkdlG828Wqf1gRjOsRPpA/oyIV+Zrnne98vBIHed1nzScF/s4pCF3UEelJxNi0LkXfZdL1G3sIvLBY9E2PSuBPBs2G68UfT67Uxs/zqofFuZBYsT3zCeOyiQa2qwawTbL6q86D/+3yzGm9u6tsTCcelyf8l2j6AnYN2b8Uxt/3EV6elGdNMExK0S0+K2FY9YfjtSjyCYjRf+nk2CNz3/gLdcyQQS2+n8r/RwCo44IUzEvva2mBmb+TlcR Mike Dollar
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDt1UkjHrSjc0ssZ1C0id/MDDVCawY3MaD6t7B1pFW54CZZrskhdUU+N3R0UQzwVNtzs58CLVmp9Yh7sxZ7BlBTx5+Vqm/y4apnnUIxw7rGv6OhQpzJD5yWnC4FferVnjbHmwTGB7U0d7i9TxL4if0fd6ah1G3lkGe4REawEbwNEaTI7VQGxhU+21ZG3SXXF5VqImqmbxi5xg2otKOk7mV0jqG5Wy6skxdbbUl8kKvh8nlgE1PeE2rSUTAZA8qfH4HyoHg1QWgGN0uibd84sXHlLhTSMYCJ7+e42ESShclztvAVcruooJM/a/H6xpaL1Dd88s7ICyKH0F8wEddIEzZ3 Ben Gillett" > /home/user/.ssh/authorized_keys
chmod 600 /home/user/.ssh/authorized_keys
chown -R user:user /home/user/.ssh

###############################
## Get and run OL7 Hardening ##
###############################

#ToDo
