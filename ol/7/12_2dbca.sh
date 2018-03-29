#!/usr/bin/env bash
set -ex
#change file permissions to allow oracle to run them
chown oracle:oinstall 12_2dbca.rsp
chmod 664 12_2dbca.rsp

cd /u01/app/oracle/product/12.2.0/dbhome_1/bin
su oracle -c './dbca -silent -createDatabase -responseFile ~/dbca_response.rsp '
if [$? = -1; then
echo 'dbca failed to complete'
exit
fi