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
	printf "  %s %-20s%s\n" "-w" "[PASSWORD]" "Database password"
	printf "  %s %-20s%s\n" "-h" "" "Prints this menu"
}

# Process arguments
while getopts ":c::p::w::h" opt; do
	case "${opt}" in
		c)
			dbname="${OPTARG}"
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
# sed -i "s/gdbName=orcl.yleo.us/gdbName=${dbname}.yleo.us/g" /home/oracle/12_1dbca.rsp
# sed -i "s/sid=orcl/sid=${dbname}/g" /home/oracle/12_1dbca.rsp
# sed -i "s/sysPassword=/sysPassword=${password}/g" /home/oracle/12_1dbca.rsp
# sed -i "s/systemPassword=/systemPassword=${password}/g" /home/oracle/12_1dbca.rsp
# sed -i "s/DB_UNIQUE_NAME=orcl/DB_UNIQUE_NAME=${dbname}/g " /home/oracle/12_1dbca.rsp
# sed -i "s/DB_NAME=orcl/DB_NAME=${dbname}/g" /home/oracle/12_1dbca.rsp
# sed -i "s/SID=orcl/SID=${dbname}/g" /home/oracle/12_1dbca.rsp
# sed -i "s/db_recovery_file_dest={ORACLE_BASE}/db_recovery_file_dest=u03/g" /home/oracle/12_1dbca.rsp
# sed -i "s/db_create_file_dest={ORACLE_BASE}/db_create_file_dest=u02/g" /home/oracle/12_1dbca.rsp
# sed -i "s/db_name=orcl/db_name=${dbname}/g" /home/oracle/12_1dbca.rsp
echo ${dbname}
su oracle -c'export ORACLE_HOME=/u01/app/oracle/product/12.1.0/dbhome_1/'
su oracle -c'export PATH=/u01/app/oracle/product/12.1.0/dbhome_1/bin'
cd /u01/app/oracle/product/12.1.0/dbhome_1/bin

su oracle -c './dbca -silent \
 -createDatabase \
 -templateName General_Purpose.dbc \
 -gdbName dbname \
 -sid dbname    \
 -sysPassword password \
 -systemPassword password \
 -datafileDestination /u02/oradata/{DB_UNIQUE_NAME}/ \
 -recoveryAreaDestination /u03/fast_recovery_area/{DB_UNIQUE_NAME}/ \
 -characterSet AL32UTF8 \
 -memoryPercentage 40 \
 '

if [ $? = -1 ]; then
	echo 'dbca failed to complete'
	exit
fi

	# -createDatabase
	# 	-templateName <name of an existing template in default location or the complete template path>
	# 	[-cloneTemplate]
	# 	-gdbName <global database name>
	# 	[-ignorePreReqs] <ignore prerequisite checks for current operation>
	# 	[-sid <database system identifier>]
	# 	[-createAsContainerDatabase <true|false>]
	# 		[-numberOfPDBs <Number of Pluggable databases to be created, default is 0>]
	# 		[-pdbName <New Pluggable Database Name>]
	# 		[-pdbAdminPassword <PDB Administrator user Password, required only when creating new PDB>]
	# 	[-sysPassword <SYS user password>]
	# 	[-systemPassword <SYSTEM user password>]
	# 	[-emConfiguration <DBEXPRESS|CENTRAL|BOTH|NONE>]
	# 		-dbsnmpPassword     <DBSNMP user password>
	# 		[-omsHost     <EM management server host name>
	# 		-omsPort     <EM management server port number>
	# 		-emUser     <EM Admin username to add or modify targets>
	# 		-emPassword     <EM Admin user password>
	# 		-emExpressPort     <EM Database Express port number>]]
	# 	[-dvConfiguration <true | false Specify "true" to configure and enable Database Vault 
	# 		-dvUserName     <Specify Database Vault Owner user name>
	# 		-dvUserPassword     <Specify Database Vault Owner password>
	# 		-dvAccountManagerName     <Specify separate Database Vault Account Manager >
	# 		-dvAccountManagerPassword     <Specify Database Vault Account Manager password>]
	# 	[-olsConfiguration <true | false Specify "true" to configure and enable Oracle Label Security >
	# 	[-datafileDestination <destination directory for all database files.> | 
 	# 	-datafileNames <a text file containing database objects such as controlfiles, tablespaces, redo log files and spfile to their corresponding raw device file names mappings in name=value format.>]
	# 	[-redoLogFileSize <size of each redo log file in megabytes>]
	# 	[-recoveryAreaDestination <destination directory for all recovery files. Specify "NONE" for disabling Fast Recovery Area.>]
	# 	[-datafileJarLocation  <location of the data file jar, used only for clone database creation>]
	# 	[-storageType < FS | ASM > 
	# 		[-asmsnmpPassword     <ASMSNMP password for ASM monitoring>]
	# 		 -diskGroupName   <database area disk group name>
	# 		 -recoveryGroupName       <recovery area disk group name>
	# 	[-characterSet <character set for the database>]
	# 	[-nationalCharacterSet  <national character set for the database>]
	# 	[-registerWithDirService <true | false> 
	# 		-dirServiceUserName    <user name for directory service>
	# 		-dirServicePassword    <password for directory service >
	# 		-walletPassword    <password for database wallet >]
	# 	[-listeners  <list of listeners to configure the database with>]
	# 	[-variablesFile   <file name for the variable-value pair for variables in the template>]]
	# 	[-variables  <comma separated list of name=value pairs>]
	# 	[-initParams <comma separated list of name=value pairs>]
	# 	[-sampleSchema  <true | false> ]
	# 	[-memoryPercentage <percentage of physical memory for Oracle>]
	# 	[-automaticMemoryManagement <true | false> ]
	# 	[-totalMemory <memory allocated for Oracle in MB>]
	# 	[-databaseType <MULTIPURPOSE|DATA_WAREHOUSING|OLTP>]]


if [ $? = -1 ]; then
	echo 'dbca failed to complete'
	exit
fi