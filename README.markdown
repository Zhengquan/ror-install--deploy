======================
A script to auto deploy rails app
ruby version: 1.8
rails version: 3.0
rubygem version: 1.8.6
passenger version: *
redis version: 2.2.12

11-08-05
 System requirement:
   OS:Ubuntu 10.04
   FrameWork: Ruby On Rails
   DB: Mysql + redis
 Notes:
 -----
   puts the startup scripts to the $INSTALL_PATH firstly
   if you wants to change the version of packages,you should change the 
   URL of the package defined in this script.
  
 Others:
 ------
   Some Recommands from the library of linode! (^_^)
   Any problem please email me.
   email: yangzhengquan#gmail.com
   (change the '#' to '@' first)
   
 Bug fix:
 -------
   Host:Ubuntu 10.04 LTS
   System: **-laptop 2.6.32-28-generic #55-Ubuntu
   Problem:  Cant't start the mysqld service ,when try to this,"Fake initctl called, doing nothing" is displayed.
   Solve:  
		sudo mv /sbin/initctl /sbin/initctl.FAKE
		sudo mv ln -s /sbin/initctl.REAL /sbin/initctl

		then:
		sudo start mysql
