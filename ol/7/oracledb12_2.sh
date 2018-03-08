#!/usr/bin/env bash
# must be ran as root
#This file will install Oracle Database 12.2 on and Oracle Linux 7 box. It will then patch the installation up to March 2018.

set -x
password=($1)

cd /
# download required install files
wget --user=thirdparty --password=${password} --save-cookies mycookies.txt  https://download.truemark.io/oracle/Oracle%20Database%2012.2/linuxx64_12201_database.zip
wget --user=thirdparty --password=${password} --save-cookies mycookies.txt  https://download.truemark.io/oracle/Oracle%20Database%2012.2/p27001739_122010_Linux-x86-64.zip
wget --user=thirdparty --password=${password} --save-cookies mycookies.txt  https://download.truemark.io/oracle/Oracle%20Database%2012.2/p27105253_122010_Linux-x86-64.zip
wget --user=thirdparty --password=${password} --save-cookies mycookies.txt  https://download.truemark.io/oracle/Oracle%20Database%2012.2/p6880880_122010_Linux-x86-64.zip

yum -y install oracle-database-server-12cR2-preinstall
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
mv /linuxx64_12201_database.zip .
unzip linuxx64_12201_database.zip 
echo 'unzipped everything'

# kick off installation
mv ~/installs/ol/7/db_install12_2.rsp /home/oracle
cd /u01/app/oracle/database
su oracle -c './runInstaller -silent -waitforcompletion -responseFile /home/oracle/db_install12_2.rsp'
if [$? = -1]; then
	exit
fi
/u01/app/oracle/product/12.2.0/dbhome_1/root.sh

#begin patching installation
cd /u01/app/oracle/product/12.2.0/dbhome_1
mv OPatch/ Opatch_dupO	
mv /p6880880_122010_Linux-x86-64.zip .

unzip p6880880_122010_Linux-x86-64.zip	
chown -R oracle OPatch
cd OPatch
mv /p27105253_122010_Linux-x86-64.zip .
mv p27001739_122010_Linux-x86-64.zip .
unzip p27105253_122010_Linux-x86-64.zip 
unzip p27001739_122010_Linux-x86-64.zip
# give oracle ownership of file
chown -R oracle 27001739/
chown -R oracle 27105253/
cd 27001739
su oracle -c './../opatch apply -silent'

cd ../27105253
su oracle -c './../opatch apply -silent'
