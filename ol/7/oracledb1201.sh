#!/usr/bin/env bash
# must be ran as root



# need 4 files downloaded and placed in root directory to complete
#	linuxamd64_12102_database_1of2.zip
#	linuxamd64_12102_database_2of2.zip
#	p6880880_121010_LINUX.zip
#	p26925311_121020_Linux-x86-64.zip 
#

#!/usr/bin/env bash
set -x
trap read debug
echo 'The file opened- Good Job!'
su - root
#yum -Y install java
echo 'begin yum install'
yum -y install oracle-rdbms-server-12cR1-preinstall
echo 'finish install'

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

#download the four files.
# use the google links
# should make it easier
#part 1 of oracle download
echo "Downloading Oracle database part 1"
wget https://drive.google.com/open?id=1T95SgzsWXGRc3PLwJ2t7QjZVAwKDmKLs
#part 2 of oracle download
echo "Downloading Oracle database part 2"
wget https://drive.google.com/open?id=10jLztvyTEtGZAse3zH4q7hB5Q5vCFPIN

# unzip base download- need to know where theses downloads will be located on host.
unzip linuxamd64_12102_database_1of2.zip 
unzip linuxamd64_12102_database_2of2.zip 
echo 'unzipped everything'
# change to oracle user
su - oracle
cd database/response
# insert into response file
sed -i 's#oracle.install.option=#oracle.install.option=INSTALL_DB_SWONLY#g' db_install.rsp
sed -i 's#UNIX_GROUP_NAME=#UNIX_GROUP_NAME=oinstall#g' db_install.rsp
sed -i 's#INVENTORY_LOCATION=#INVENTORY_LOCATION=/etc/oraInventory#g' db_install.rsp
#sed -i 's#ORACLE_HOSTNAME=#ORACLE_HOSTNAME=pandora.krenger.ch#g' db_install.rsp
sed -i 's#ORACLE_HOME=#ORACLE_HOME=/u01/app/oracle/product/12.1.0/dbhome_1#g' db_install.rsp
sed -i 's#ORACLE_BASE=#ORACLE_BASE=/u01/app/oracle#g' db_install.rsp
sed -i 's#oracle.install.db.InstallEdition=#oracle.install.db.InstallEdition=EE#g' db_install.rsp
sed -i 's#oracle.install.db.DBA_GROUP=#oracle.install.db.DBA_GROUP=dba#g' db_install.rsp
sed -i 's#SECURITY_UPDATES_VIA_MYORACLESUPPORT=#SECURITY_UPDATES_VIA_MYORACLESUPPORT=false#g' db_install.rsp
sed -i 's#oracle.install.db.DGDBA_GROUP=#oracle.install.db.DGDBA_GROUP=dba#g' db_install.rsp
sed -i 's#oracle.install.db.KMDBA_GROUP=#oracle.install.db.KMDBA_GROUP=dba#g' db_install.rsp
sed -i 's#DECLINE_SECURITY_UPDATES=#DECLINE_SECURITY_UPDATES=true#g' db_install.rsp
sed -i 's#oracle.installer.autoupdates.option=#oracle.installer.autoupdates.option=SKIP_UPDATES#g' db_install.rsp
sed -i 's#oracle.install.db.BACKUPDBA_GROUP=#oracle.install.db.BACKUPDBA_GROUP=dba#g' db_install.rsp
echo 'updated response file'
# kick off installation
 ./runInstaller -silent -responseFile ~/database/response/db_install.rsp
su - root
/u01/app/oracle/product/12.1.0/dbhome_1/root.sh
su - oracle
cd u01/app/oracle/product/12.1.0/dbhome_1
mv OPatch/ Opatch_dupO	
# download OPatch from google drive.
wget https://drive.google.com/open?id=13nRRfGxwrrnYGLwUXsLZSpQoRcLGU4qc
#install new version of opatch
unzip p6880880_121010_LINUX.zip	
cd OPatch

#download  latest patch set from google drive.
wget https://drive.google.com/open?id=1-1GQsChizuTHGmUgTqft4xod49oa1FH7
unzip p26925311_121020_Linux-x86-64.zip 
#install patches  need to make neater.
cd 26925311
./../opatch apply -jdk ../../jdk





