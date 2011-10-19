#!/usr/bin/env bash
###BEGIN INFO
# System: Ubuntu 10.04 LTS 32bit
# DB: mysql
# Desc  : 自动化安装Mysql备份工具xtrabackup 
# Author: yangzhengquan@gmail.com
###END INFO
export PATH=/usr/sbin:/usr/bin:/sbin:/bin
export DEB_TOOL="apt-get"

set -e 
if [ `id -u` -ne 0 ];	then
  echo "Execute this script with root!"
  exit 1
fi

##确定版本号
release=`lsb_release -r |awk '{print $2}'`
codename="lucid"
if [ version = "10.10" ]; then
  codename="maverick"
fi
if [ version = "8.04" ]; then
  codename="hardy"
fi
echo "安装xtrabackup的APT源公钥..."
sudo gpg --keyserver  hkp://keys.gnupg.net --recv-keys 1C4CBDCDCD2EFD2A
sudo gpg -a --export CD2EFD2A | apt-key add -

echo "添加源地址至sources.list中..."
cat >>/etc/apt/sources.list<<END_OF
deb http://repo.percona.com/apt $codename main
deb-src http://repo.percona.com/apt $codename main
END_OF

##更新软件包索引
$DEB_TOOL update
##安装软件包
$DEB_TOOL install  xtrabackup

echo "Successed!"
exit 0
