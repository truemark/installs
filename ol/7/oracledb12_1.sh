#!/usr/bin/env bash
# must be ran as root
#This file will install Oracle Database 12.1 on and Oracle Linux 7 box. It will then patch the installation up to March 2018.

set -ex
password=($1)

cd /
# download required install files
wget --user=thirdparty --password=${password} --save-cookies mycookies.txt  https://download.truemark.io/oracle/Oracle%20Database%2012.1/p6880880_122010_Linux-x86-64.zip
wget --user=thirdparty --password=${password} --save-cookies mycookies.txt  https://download.truemark.io/oracle/Oracle%20Database%2012.1/p26925311_121020_Linux-x86-64.zip
wget --user=thirdparty --password=${password} --save-cookies mycookies.txt  https://download.truemark.io/oracle/Oracle%20Database%2012.1/linuxamd64_12102_database_2of2.zip
wget --user=thirdparty --password=${password} --save-cookies mycookies.txt  https://download.truemark.io/oracle/Oracle%20Database%2012.1/linuxamd64_12102_database_1of2.zip

set +e
yum -y install oracle-rdbms-server-12cR1-preinstall
cd /etc
# make file for oraInst.loc
touch oraInst.loc
echo "inventory_loc=/u01/app/oraInventory" >> oraInst.loc
echo "inst_group=oinstall" >> oraInst.loc
chown oracle:oinstall oraInst.loc
chmod 664 oraInst.loc

if [ ! -d "/u01/app/oracle" ]; then
mkdir -p /u01/app/oracle
mkdir -p /u01/app/oraInventory
chown -R oracle:dba /u01
fi

cd /u01/app/oracle

# move base downloads and then unzip them
mv /linuxamd64_12102_database_1of2.zip .
mv /linuxamd64_12102_database_2of2.zip .
unzip linuxamd64_12102_database_1of2.zip 
unzip linuxamd64_12102_database_2of2.zip 
echo 'unzipped everything'

# kick off installation
mv ~/installs/ol/7/db_install12_1.rsp /home/oracle
cd /u01/app/oracle/database
su oracle -c './runInstaller -silent -waitforcompletion -responseFile /home/oracle/db_install12_1.rsp'
if [$? = -1]; then
	exit
fi
/u01/app/oracle/product/12.1.0/dbhome_1/root.sh

#begin patching installation
cd /u01/app/oracle/product/12.1.0/dbhome_1
mv OPatch/ Opatch_dupO	
mv /p6880880_122010_Linux-x86-64.zip .
unzip p6880880_122010_Linux-x86-64.zip	
chown -R oracle OPatch
cd OPatch
mv /p26925311_121020_Linux-x86-64.zip .
unzip p26925311_121020_Linux-x86-64.zip 
# give oracle ownership of file
chown -R oracle 26925311/
cd 26925311
su oracle -c './../opatch apply -silent'






