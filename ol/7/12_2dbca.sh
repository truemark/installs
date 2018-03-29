#!/usr/bin/env bash
set -ex
#change file permissions to allow oracle to run them
dbname=($1)
password=($2)
#update commands with variable values

#Specify Fast Recovery Area Size to be at least three times the database size. update in rsp file. need to determine what size it should be
sed -i "s/gdbName=orcl.yleo.us/gdbName=${dbname}.yleo.us/g" 12_2dbca.rsp
sed -i "s/sid=orcl/sid=${dbname}/g" 12_2dbca.rsp
sed -i "s/pdbName=PDB1/pdbName=PDB${dbname}/g" 12_2dbca.rsp
sed -i "s/pdbAdminPassword=/pdbAdminPassword=${password}/g" 12_2dbca.rsp
sed -i "s/sysPassword=/sysPassword=${password}/g" 12_2dbca.rsp
sed -i "s/systemPassword=/systemPassword=${password}/g" 12_2dbca.rsp

chown oracle:oinstall 12_2dbca.rsp
chmod 664 12_2dbca.rsp
mv 12_2dbca.rsp /home/oracle/

cd /u01/app/oracle/product/12.2.0/dbhome_1/bin
su oracle -c './dbca -silent -createDatabase -responseFile ~/12_2dbca.rsp'
if [$? = -1; then
echo 'dbca failed to complete'
exit
fi