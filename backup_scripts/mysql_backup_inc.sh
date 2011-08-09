#!/bin/bash

###BEGIN INFO
#System: Ubuntu 10.04
#Author: yangkit
#Email:  yangzhengquan@gmail.com
#Desc: a script to backup mysql using incremental backup
###END INFO
PATH=/usr/sbin:/usr/bin:/sbin:/bin
##mysql backup scripts
BACK_SCRIPT=""
##the folder which backup files puts in
TARGET_DIR=""
function error_prompt ()
{
	echo "Error:$1"
	exit 1
}
set -e
if [ `id -u` -ne 0 ] ; then
	error_prompt "Execute this script with root permission!"
fi