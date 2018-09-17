## YoungLiving Oracle Linux 7 Pre Install Script
## Must be ran as root
## PLEASE NOTE THIS SCRIPT ASSUMES YOU HAVE ADDED A 200G DRIVE

#########################
## Setup orasoft / u01 ##
#########################

echo "- - -" > /sys/class/scsi_host/host0/scan
echo "- - -" > /sys/class/scsi_host/host1/scan
echo "- - -" > /sys/class/scsi_host/host2/scan

sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF | fdisk /dev/sdb
  o # clear the in memory partition table
  n # new partition
  p # primary partition
  1 # partition number 1
    # default - start at beginning of disk
    # default - end at end of disk
  t # partition type
  8e # partition type Linux LVM
  p # print the in-memory partition table
  w # write the partition table
  q # and we're done
EOF

pvcreate /dev/sdb1
vgcreate orasoft /dev/sdb1
lvcreate -L75G -nu01 orasoft
mkfs.ext4 /dev/orasoft/u01
mkdir -p /u01
echo "/dev/mapper/orasoft-u01 /u01 ext4 defaults 1 2" >> /etc/fstab
mount -a

## Install OL DB related software ##
yum install compat-libcap1 compat-libstdc++-33 gcc gcc-c++ glibc-devel ksh libstdc++-devel libaio-devel elfutils-libelf-devel nscd oracle-database-server-12cR2-preinstall -y

###############################
## Enabling the new services ##
###############################

firewall-cmd --zone=public --permanent --add-service=oracle-oem
firewall-cmd --zone=public --permanent --add-service=oracle-listener
