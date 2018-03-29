#!/usr/bin/env bash
set -ex
#change file permissions to allow oracle to run them
dbname=($1)
password=($2)
#update commands with variable values
sed -i "s/gdbName=orcl.yleo.us = gdbName=${dbname}.yleo.us" 12_2dbca.rsp
sed -i "s/sid=orcl = sid=${dbname}" 12_2dbca.rsp
sed -i "s/pdbName=PDB1 = pdbName=PDB${dbname}" 12_2dbca.rsp
sed -i "s/sysPassword= = sysPassword=${password}" 12_2dbca.rsp
sed -i "s/systemPassword=  = systemPassword=${password}" 12_2dbca.rsp

chown oracle:oinstall 12_2dbca.rsp
chmod 664 12_2dbca.rsp

cd /u01/app/oracle/product/12.2.0/dbhome_1/bin
su oracle -c './dbca -silent -createDatabase -responseFile ~/dbca_response.rsp '
if [$? = -1; then
echo 'dbca failed to complete'
exit
fi