#!/bin/bash
###BEGIN INFO

#System: Ubuntu 10.04
#Author: yangkit
#Email:  yangzhengquan@gmail.com
#Desc:   a shell script to make the backup jobs be cron tasks 
###END INFO
##root 
set -e
##Global Settings
PATH=/usr/sbin:/usr/bin:/sbin:/bin
MYSQL_UPDATE_VOTES="mysql uroot -e \"update users set vote_times_per_day = 30\""
MYSQL_BACKUP_SCRIPT="./backup_scripts/mysql_back.sh"
MYSQL_PATH="/usr/bin/mysql"
CRON_CONFIG_PATH="/etc/crontab"
LOG_PATH="/var/log/backup.log"

if [ `id -u` -ne 0 ];	then
	exit 1;
fi
function error_prompt ()
{
	echo "Error:$1!"
	exit 1
}
##add cron task
echo "[+]Writing cron jobs into ${CRON_CONFIG_PATH}..."
echo "[+]Add the update task on vote_times_per_day..."
cat <<END_OF >>$CRON_CONFIG_PATH
##cron task ,log info when occured error
0 0 * * * root 	$MYSQL_UPDATE_VOTES || ( echo "\$(date) \$(hostname) ${MYSQL_UPDATE_VOTES} failed!" >> $LOG_PATH)
END_OF

##add mysql backup task

echo "Complete!"
exit 0
