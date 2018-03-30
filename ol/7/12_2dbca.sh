#!/usr/bin/env bash

# Exit on errors
set -e

if [ $(whoami) != "root" ]; then
	echo "script must be run as root"
	exit
fi

function usage() {
	echo "Usage: $0"
	printf "  %s %-20s%s\n" "-c" "[CDBNAME]" "Container database name"
	printf "  %s %-20s%s\n" "-p" "[PDBNAME]" "Pluggable database name"
	printf "  %s %-20s%s\n" "-w" "[PASSWORD]" "Database password"
	printf "  %s %-20s%s\n" "-h" "" "Prints this menu"
}

# Process arguments
while getopts ":c::p::w::h" opt; do
	case "${opt}" in
		c)
			dbname="${OPTARG}"
			;;
		p)
			pdbname="${OPTARG}"
			;;
		w)
			password="${OPTARG}"
			;;
		h)
			usage
			exit 0
			;;
	esac
done

# Validate arguments
if [ -z ${dbname} ]; then
	echo "dbname is a required parameter"
	usage
	exit 1
fi
if [ -z ${pdbname} ]; then
	echo "pdbname is a required parameter"
	usage
	exit 1
fi
if [ -z ${password} ]; then
	echo "password is a required parameter"
	usage
	exit 1
fi

# Exit on uset varibles
set -u

#change file permissions to allow oracle to run them

#to do
# update datafile destintion to u02
# recovery area destination should be on u03
# create u02/oracle
# create u03/oracle
# getOps allows better variable input.

#update commands with variable values
#create directories
mkdir -p /u02/oradata/
mkdir -p /u03/fast_recovery_area/
chown oracle:oinstall /u02/oradata/
chown oracle:oinstall /u03/fast_recovery_area/
chmod 775 /u02/oradata/
chmod 775 /u03/fast_recovery_area/

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
