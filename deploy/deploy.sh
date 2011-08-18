#!/bin/bash
###BEGIN INFO
# System: Ubuntu 10.04 LTS 32bit
# Framwork : Ruby On Rails
# Deploy_tool:Capistrano
# Desc  :  a scipt to deploy ror app using Capistrano
# Author: yangzhengquan@gmail.com
###END INFO
export PATH=/usr/sbin:/usr/bin:/sbin:/bin

APPLICATION_NAME="batmanreturns"
set -e
function error_prompt ()
{
	echo -e "Error:$1"
	exit 1
}
function info_prompt()
{
	echo -e "Info:$1"
}
if [ $# -eq 0 ]  ; then
	error_prompt "\e[0;31m./deploy.sh [optionos] \e[0m"
fi