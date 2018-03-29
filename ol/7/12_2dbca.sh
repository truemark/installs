#!/usr/bin/env bash
set -ex
#change file permissions to allow oracle to run them

#to do
# update datafile destintion to u02
# recovery area destination should be on u03
# create u02/oracle
# create u03/oracle
# getOps allows better variable input.

dbname=($1)
password=($2)
pdbname=($3)
#update commands with variable values
#create directories
mkdir u02/oradata/
mkdir /u03/fast_recovery_area/

#Specify Fast Recovery Area Size to be at least three times the database size. update in rsp file. need to determine what size it should be
sed -i "s/gdbName=orcl.yleo.us/gdbName=${dbname}.yleo.us/g" 12_2dbca.rsp
sed -i "s/sid=orcl/sid=${dbname}/g" 12_2dbca.rsp
sed -i "s/pdbName=PDB1/pdbName=${pdbname}/g" 12_2dbca.rsp
sed -i "s/pdbAdminPassword=/pdbAdminPassword=${password}/g" 12_2dbca.rsp
sed -i "s/sysPassword=/sysPassword=${password}/g" 12_2dbca.rsp
sed -i "s/systemPassword=/systemPassword=${password}/g" 12_2dbca.rsp
sed -i "s/DB_UNIQUE_NAME=orcl/DB_UNIQUE_NAME=${dbname}/g " 12_2dbca.rsp
sed -i "s/PDB_NAME=/PDB_NAME=${pdbname}/g" 12_2dbca.rsp
sed -i "s/DB_NAME=orcl/DB_NAME=${dbname}/g" 12_2dbca.rsp
sed -i "s/SID=orcl/SID=${dbname}/g" 12_2dbca.rsp
sed -i "s/db_recovery_file_dest={ORACLE_BASE}/db_recovery_file_dest=u03/g" 12_2dbca.rsp
sed -i "s/db_create_file_dest={ORACLE_BASE}/db_create_file_dest=u02/g" 12_2dbca.rsp
sed -i "s/db_name=orcl/db_name=${dbname}/g" 12_2dbca.rsp



chown oracle:oinstall 12_2dbca.rsp
chmod 664 12_2dbca.rsp
mv 12_2dbca.rsp /home/oracle/

cd /u01/app/oracle/product/12.2.0/dbhome_1/bin
su oracle -c './dbca -silent -createDatabase -responseFile ~/12_2dbca.rsp'
if [$? = -1; then
echo 'dbca failed to complete'
exit
fi