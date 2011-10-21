#!/usr/bin/env bash
###BEGIN INFO
# System: Ubuntu
# DB: mysql
# Desc  :  a scipt to backup mysql databases using xtrabackup
# Author: yangzhengquan@gmail.com
###END INFO

#the executable xtrabackup tool
export XTRABACKUP_BIN=`which xtrabackup_55`
#the data location of mysql
export MYSQL_DATA_DIR="/var/lib/mysql"
#the configuration file of mysql
export MYSQL_CONF_FILE="/etc/mysql/my.cnf"

#the full backup target dir
export BACKUP_TARGET_DIR="$HOME/backup"
#the incremental backup target directory
export INCREMENTAL_TARGET_DIR="$HOME/delta"

#the log file
export LOG_LOCATION="$HOME/backup_v1.log"
#the database to be backuped
export BACKUP_DATABASE="batmanreturns_development"
#the compress tool
export COMPRESS_TOOL=`which tar`
#the ftp tool
export FTP_TOOL=`which ftp`
#the script to install xtrabackup
export XTRABACKUP_INSTALL_SCRIPT="https://raw.github.com/Zhengquan/ror-install--deploy/master/ror_install/xtrabackup_install.sh"
#the system environment path
export PATH=/usr/sbin:/usr/bin:/sbin:/bin

#Ftp settings
export FTP_SITE_URL="192.168.56.101"
export FTP_USER="backup"
export FTP_PASSWORD="password"
export FTP_TARGET_DIR="path"

#app information
VERSION=1.1

set -e
function test_env()
{
    if [ -z "$XTRABACKUP_BIN" ] ; then
        error_prompt "You Should install xtrabackup first!\nINSTALL:$XTRABACKUP_INSTALL_SCRIPT"
    fi

	if [ ! -d "$BACKUP_TARGET_DIR" ] ;then
		mkdir $BACKUP_TARGET_DIR
	fi
	
	if [ ! -d "$INCREMENTAL_TARGET_DIR" ] ;then
		mkdir $INCREMENTAL_TARGET_DIR
	fi

	if [ ! -d "$MYSQL_DATA_DIR" ] ;then
		error_prompt "the mysql data directory is not existed!"
	fi

}
function error_prompt()
{
    echo -e  "\e[0;31mError:$1\e[0m"
    exit 1
}
function log()
{
    echo $1
    echo "$(date +%Y-%m-%d\ %R:%S):$1" >> $LOG_LOCATION
    return $?
}
function check_permission()
{
	if [ $(id -u) -ne 0 ]  ; then
		error_prompt "You should execute this script with root privilege!"
	fi
}

function transfer_to_ftp()
{
	ftp -n $FTP_SITE_URL >>$LOG_LOCATION 2>/dev/null <<END_OF
user	$FTP_USER	$FTP_PASSWORD
cd		$FTP_TARGET_DIR
binary
put		$1
bye
END_OF
return $?
}
function full_backup()
{
    	#clean the target folder firstly
	local item=`ls $BACKUP_TARGET_DIR | wc -l`
	if [ $item -ne 0 -a -n ${BACKUP_TARGET_DIR} ] ; then
	    rm -rf ${BACKUP_TARGET_DIR}/*
	fi

	#backup data file
	trap "" SIGINT
	log "---Full-backing up the database $BACKUP_DATABASE---------"
	$XTRABACKUP_BIN --defaults-file=$MYSQL_CONF_FILE --backup --target-dir=$BACKUP_TARGET_DIR
	#backup database structure
	cp -r ${MYSQL_DATA_DIR}/${BACKUP_DATABASE} $BACKUP_TARGET_DIR

	#change to the target folder's parent path
	cd $BACKUP_TARGET_DIR
	cd ..

    	#get file name
	local package_name="full_$(date +%Y-%m-%d@%H_%M_%S).tar.gz"
	log "Package files into $(pwd)/${package_name}"
	
    	#compress and package the files
    	$COMPRESS_TOOL zcf $package_name $BACKUP_TARGET_DIR
	sync;

    	#transfer the files into ftp site
	log "Transfer to ftp site:$FTP_SITE_URL"
	transfer_to_ftp $package_name
	log "---------Full-Backup is completed!------------"
	
    	#delete the tar.gz file
	rm *.tar.gz
	trap SIGINT
	return $?
}

function incremental_backup()
{
	log "-------Incremental-backing up the database $BACKUP_DATABASE---------"
	#if the base folder is empty,execute the full backup firstly
	local item=`ls $BACKUP_TARGET_DIR | wc -l`
	if [ $item -eq 0 ] ; then
		full_backup
	fi
	#if the delta folder is not empty ,clear the folder firstly
	item=`ls $INCREMENTAL_TARGET_DIR | wc -l`
	if [ $item -ne 0 ] ;then
		rm -rf $INCREMENTAL_TARGET_DIR/*
	fi

	trap "" SIGINT
	#execute the incremental_backup
	$XTRABACKUP_BIN --defaults-file=$MYSQL_CONF_FILE --backup --target-dir=$INCREMENTAL_TARGET_DIR --incremental-basedir=$BACKUP_TARGET_DIR

	cd $BACKUP_TARGET_DIR
	cd ..

    	#get file name
	local package_name="incremental_$(date +%Y-%m-%d@%H_%M_%S).tar.gz"
	log "Package files into $(pwd)/${package_name}"
    	#compress and package the files
    	$COMPRESS_TOOL zcf $package_name $INCREMENTAL_TARGET_DIR
	sync;

    	#transfer the files into ftp site
	log "Transfer to ftp site:$FTP_SITE_URL"
	#change the remote location
	local remote_temp=$FTP_TARGET_DIR
	FTP_TARGET_DIR="$FTP_TARGET_DIR/incremental"
	transfer_to_ftp $package_name
	FTP_TARGET_DIR=$remote_temp

	log "Move  files to the base folder of incremental-backup"
	rm *.tar.gz
	#move the delta files into base folder
	rm -rf $BACKUP_TARGET_DIR/*
	cp -R $INCREMENTAL_TARGET_DIR/* $BACKUP_TARGET_DIR/
	
	log "-------Incremental-Backup is completed!------------"
	trap SIGINT
}
#check permisson
#check_permission
#test environment
test_env

#Begin Backup 
case $1 in
	   full)
		full_backup
		;;
incremental)
	    incremental_backup
		;;
	      *)
		error_prompt "\n\e[0;34mUsage:\nxtrabackup_script full|incremental!"
		;;
esac	
exit 0
