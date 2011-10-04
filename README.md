                        Railo Installation Script for Ubuntu

What is it?
-----------
The Railo installation script for Ubuntu is a single script that
can be executed on a Ubuntu Server to download, install and
configure the following software with minimal user interaction:

 * Ubuntu Server 10.04 LTS 64-bit; Ubuntu Server 11.04 LTS 64-bit
 * Apache 2.2.x
 * Java SE 1.6_27
 * Tomcat 7.0.22
 * Railo 3.2.3


The Latest Version
------------------
The latest version of this script can always be found at the
Github project page which is located at 
Details of the latest version can be found on the Apache HTTP
server project page under http://httpd.apache.org/.


Documentation
-------------
The file serves as the current central documentation for this
script file.


Installation
------------
Once your Ubuntu Server is running, copy this file to the server
using one of the following methods:
 scp setup-railo.sh <ubuntu-username>@<server ip>
 wget https://raw.github.com/talltroym/Railo-Ubuntu-Installer-Script/master/setup-railo.sh
  _Note:_ If you use wget you'll need to run fromdos setup-railo.sh on the file to convert the line endings.  You can install this by doing sudo aptitude install tofrodos
 Copy and paste the contents of this file from your system to a text editor

Next you need to give the script execute privileges by doing:
 sudo chmod +x setup-railo.sh

Last, execute the script by typing: sudo ./setup-railo.sh


Licensing
---------
This script is licensed under the Apache License, Version 2.0.  You can
read this license at http://www.apache.org/licenses/LICENSE-2.0
