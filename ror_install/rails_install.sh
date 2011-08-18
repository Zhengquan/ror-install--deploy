#!/bin/bash
###BEGIN INFO
# System: Ubuntu 10.04 LTS 32bit
# Framwork : Ruby On Rails
# DB: mysql
# Desc  :  a scipt to install ror env automatically
# Author: yangzhengquan@gmail.com
###END INFO
export INSTALL_PATH=/opt
export INSTALL="apt-get -y"
export DOWNLOAD=wget
export PATH=/usr/sbin:/usr/bin:/sbin:/bin
export GEM_URL="http://production.cf.rubygems.org/rubygems/rubygems-1.8.6.tgz"
export RUBYENTER_URL="http://rubyenterpriseedition.googlecode.com/files/ruby-enterprise-1.8.7-2011.03.tar.gz"
export REDIS_URL="http://redis.googlecode.com/files/redis-2.2.12.tar.gz"

###configure redis¡¢Nginx startup scripts
export CONFIGFILE_PATH=~
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
	error_prompt "\n
\e[0;31m./rails_install.sh  [ALL|WebServer|DBServer|Capistrano]:\e[0m
\e[0;32mALL :\e[0m  environment with mysql server & redis & Nginx & Passenger
\e[0;32mWebServer:\e[0mwith Nginx & Passenger & Assets
\e[0;32mDBServer:\e[0m with only  redis & mysql server
\e[0;32mCapistrano:\e[0mthe Capistrano client to deploy ror app\e[0m"
fi

info_prompt "Ensure that the urls of software have been updated to the newest!"
##check if the directory existed
[ -d $INSTALL_PATH ] || error_prompt "$ is not exist!"

##root
if [ `id -u` -ne 0 ];	then
	error_prompt "Execute this script with root!"
fi
##update system software index
$INSTALL update
##declare functions
##install ruby & gems
function rubygems_install()
{
	##install ruby
	info_prompt "[+]Installing ruby..."
	$INSTALL install wget build-essential ruby1.8 ruby1.8-dev \
							irb1.8 rdoc1.8 zlib1g-dev \
							libopenssl-ruby1.8 libopenssl-ruby \
							libzlib-ruby libssl-dev libpcre3-dev \
							libcurl4-openssl-dev libmysqlclient15-dev \
							libmysql-ruby libreadline5-dev libxml2-dev \
							python-setuptools  libxslt1-dev 
							

	info_prompt "[+]Making symbolic link to ruby1.8..."
	##make symbolic link to ruby
	ln -s /usr/bin/ruby1.8 /usr/bin/ruby || echo -n "" 
	ln -s /usr/bin/irb1.8 /usr/bin/irb || echo -n ""   

	##install gems
	cd $INSTALL_PATH
	##get file name
	file_name=${GEM_URL##*/}
	if [ ! -f $file_name ] ;then
		info_prompt "[+]Downloading gem package..."
		$DOWNLOAD $GEM_URL
	fi
	tar zxvf $file_name 
	##get dir name
	dir_name=${file_name%.*}
	cd $dir_name
	info_prompt "[+]Installing gem package..."
	ruby setup.rb 
	##make symbolic link to gem
	info_prompt "[+]Making symbolic link to gem1.8..."
	ln -s /usr/bin/gem1.8 /usr/bin/gem || echo -n "" 
	return 0
}
##install rails
function rails_install()
{
	##install rails
	info_prompt "[+]Installing rails..."
	gem install rails --no-rdoc --no-ri
	return 0
}
function nginx_passenger_install()
{
	##install passenger
	info_prompt "[+]installing passenger..."
	gem install passenger --no-rdoc --no-ri
	passenger-install-nginx-module --auto --auto-download
	##add nginx startup script
	info_prompt "[+]Adding startup scripts to /etc/inin.d/*...."
	cd $INSTALL_PATH
	if [ ! -f $CONFIGFILE_PATH/601-init-deb.sh ] ; then
		$DOWNLOAD -O $CONFIGFILE_PATH/601-init-deb.sh http://library.linode.com/assets/601-init-deb.sh
	fi
	cp -f  $CONFIGFILE_PATH/601-init-deb.sh /etc/init.d/nginx || echo -n ""
	chmod +x /etc/init.d/nginx
	/usr/sbin/update-rc.d -f nginx defaults
	return 0
}
function mysql_redis_install()
{
	##install mysql
	info_prompt "[+]installing mysql-serevr..."
	$INSTALL install mysql-server
	mysql_secure_installation
	#gem install mysql --no-rdoc --no-ri -- --with-mysql-dir=/usr/bin --with-mysql-lib=/usr/lib/mysql --with-mysql-include=/usr/include/mysql

	##install redis
	cd $INSTALL_PATH
	mkdir redis || echo -n ""
	file_name=${REDIS_URL##*/}
	if [ ! -f $file_name ] ; then
		info_prompt "[+]Downloading redis..."
		$DOWNLOAD $REDIS_URL
	fi
	file_name=${file_name//tar.gz/tgz}
	cp -f  ${REDIS_URL##*/} "$file_name"
	dir_name=${file_name%.*}
	tar zxvf $file_name >/dev/null
	rm $INSTALL_PATH/$file_name
	cd $dir_name
	make

	info_prompt "[+]installing redis..."
	cp -f  /$INSTALL_PATH/$dir_name/redis.conf /$INSTALL_PATH/redis/redis.conf  		
	cp -f  /$INSTALL_PATH/$dir_name/src/redis-benchmark /$INSTALL_PATH/redis/			
	cp -f  /$INSTALL_PATH/$dir_name/src/redis-cli /$INSTALL_PATH/redis/					
	cp -f  /$INSTALL_PATH/$dir_name/src/redis-server /$INSTALL_PATH/redis/				
	cp -f  /$INSTALL_PATH/$dir_name/src/redis-check-aof /$INSTALL_PATH/redis/			
	cp -f  /$INSTALL_PATH/$dir_name/src/redis-check-dump /$INSTALL_PATH/redis/ 	

	##install redis
	cd $INSTALL_PATH
	if [ ! -f $CONFIGFILE_PATH/629-redis-init-deb.sh ] ; then
		wget -O $CONFIGFILE_PATH/629-redis-init-deb.sh http://library.linode.com/assets/629-redis-init-deb.sh
	fi
	cp -f $CONFIGFILE_PATH/629-redis-init-deb.sh /etc/init.d/redis
	chmod +x /etc/init.d/redis
	adduser --system --no-create-home --disabled-login --disabled-password --group redis || echo -n ""
	chown -R redis:redis /$INSTALL_PATH/redis
	touch /var/log/redis.log
	chown redis:redis /var/log/redis.log
	update-rc.d -f redis defaults
	return 0
}
##install Capistrano
function cap_install()
{
	gem install capistrano --no-rdoc --no-ri
	return 0;
}
##uninstall rake 0.9.2 & install rake 0.8.7
function rake_reinstall()
{
	version=`rake -V | grep '0.9.2'`
	if [ -n "$version" ] ;then
		gem uninstall rake -v '0.9.2'
	fi
	##install rake 0.8.7
	gem install rake -v '0.8.7'
}
##update gem packages to newest
if [ "$1" = "ALL" ] ; then
	rubygems_install &&
	rails_install 	&&
	nginx_passenger_install &&
	mysql_redis_install	&&
	rake_reinstall &&
	info_prompt "ALL Complete!" &&
	exit 0
fi
##webserver=nginx+passenger+assets
if [ "$1" = "WebServer" ]; then
	rubygems_install &&
	rails_install	&&
	nginx_passenger_install &&
	rake_reinstall &&
	info_prompt "nginx & passenger & assets Complete!" &&
	exit 0
fi

if [ "$1" = "DBServer" ]; then
	rubygems_install  &&
	rails_install	&&
	rake_reinstall &&
	mysql_redis_install	&&
	info_prompt "Mysql & Redis Complete!" &&
	exit 0
fi

if [ "$1" = "Capistrano" ]; then
	rubygems_install &&
	cap_install &&
	info_prompt "Capistrano Complete!" &&
	exit 0
fi
exit 0




