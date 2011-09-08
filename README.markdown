A script to auto deploy rails app  
=================================

 ruby version: 		1.8  
 rails version: 	3.1   
 rubygem version: 	1.8.6  
 passenger version:	3.08  
 redis version: 	2.2.12  
 rake version:		0.8.7  

System requirement:  
------------------

 OS:			Ubuntu 10.04  
 FrameWork: 		Ruby On Rails  
 DB: 			Mysql + redis  
 Notes:  
   puts the startup scripts to the $INSTALL_PATH firstly if you wants to change the version of packages,you should change the URL of the package defined in this script.  
  
Others:  
------

Some Recommands from the library of linode! (^_^)  
Any problem please email me.  
   
Bug fix:  
-------
### 1
Host:Ubuntu 10.04 LTS  
System:  2.6.32-28-generic #55-Ubuntu  
Problem:  Cant't start the mysqld service ,when try to this,"Fake initctl called, doing nothing" is displayed.    
Solve:  
    `sudo mv /sbin/initctl /sbin/initctl.FAKE`  
    `sudo mv ln -s /sbin/initctl.REAL /sbin/initctl`  
then:  
    `sudo start mysql`
	
### 2
Problem description:  
Could not find a JavaScript runtime. See https://github.com/sstephenson/execjs for a list of available runtimes.  
Solve:  
Add the following into the Gemfile. 

	gem 'execjs'
	gem 'therubyracer'

Then:  

	sudo bundle

### 3
Problem description  
uninitialized constant Gem::SilentUI (NameError)  
Solve:  
Execute the following command.  

    sudo gem update bundler
