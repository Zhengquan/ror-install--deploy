#!/bin/bash
###BEGIN INFO

#System: Ubuntu 10.04
#Author: yangkit
#Email:  yangzhengquan@gmail.com
#Desc: a script to configure system,including config of mysql & redis & nginx and som cron tasks.
###END INFO
##root 
set -e
if [ `id -u` -ne 0 ];	then
	exit 1;
fi
PATH=/usr/sbin:/usr/bin:/sbin:/bin
CRON_MYSQL_COMMAND="mysql uroot -e \"update users set vote_times_per_day = 30\""
MYSQL_PATH="/usr/bin/mysql"
CRON_CONFIG_PATH="/etc/crontab"
LOG_PATH="/var/log/messages"
##add cron task
echo "[+]Writing cron jobs into ${CRON_CONFIG_PATH}..."
cat <<END_OF >>$CRON_CONFIG_PATH
##cron task ,log info when occured error
0 0 * * * root 	$CRON_MYSQL_COMMAND || ( echo "\$(date) \$(hostname) ${CRON_MYSQL_COMMAND} failed!" >> $LOG_PATH)
END_OF
echo "Complete!"
exit 0
