#!/bin/bash
###BEGIN INFO
# System: Ubuntu 10.04 LTS 32bit
# Framwork : Ruby On Rails
# DB: mysql
# Desc  :  a scipt to install ror env automatically
###END INFO
INSTALL_PATH=/opt
INSTALL="apt-get -y"
DOWNLOAD=wget
PATH=/usr/sbin:/usr/bin:/sbin:/bin
GEM_URL="http://production.cf.rubygems.org/rubygems/rubygems-1.8.6.tgz"
RUBYENTER_URL="http://rubyenterpriseedition.googlecode.com/files/ruby-enterprise-1.8.7-2011.03.tar.gz"
REDIS_URL="http://redis.googlecode.com/files/redis-2.2.12.tar.gz"

###configure redis��Nginx startup scripts��
CONFIGFILE_PATH=/home/vigoss/test
set -e
function error_prompt ()
{
	echo "Error:$1"
	exit 1
}
function info_prompt()
{
	echo "Info:$1"
}
##update gem packages to newest
info_prompt "Ensure that the urls of software have been updated to the newest!"
##check if the directory existed
[ -d $INSTALL_PATH ] || error_prompt "$ is not exist!"

##root
if [ `id -u` -ne 0 ];	then
	error_prompt "Execute this script with root!"
fi
##update system
$INSTALL update && $INSTALL upgrade  

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

##install rails
info_prompt "[+]Installing rails..."
gem install rails 


##install assenger
info_prompt "[+]installing passenger..."
gem install passenger
passenger-install-nginx-module
##add nginx startup script
info_prompt "[+]Adding startup scripts to /etc/inin.d/*...."
cd $INSTALL_PATH
if [ ! -f $CONFIGFILE_PATH/601-init-deb.sh ] ; then
	$DOWNLOAD -O $CONFIGFILE_PATH/601-init-deb.sh http://library.linode.com/assets/601-init-deb.sh
fi
cp -f  $CONFIGFILE_PATH/601-init-deb.sh /etc/init.d/nginx || echo -n ""
chmod +x /etc/init.d/nginx
/usr/sbin/update-rc.d -f nginx defaults

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
info_prompt "Complete!"
exit 0



