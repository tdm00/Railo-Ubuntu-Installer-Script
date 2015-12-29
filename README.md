# Railo Installation Script for Ubuntu

## What is this script do?
The Railo installation script for Ubuntu is a single script that can be executed on a Ubuntu Server to download, install and configure the following software with minimal user interaction:

 * Ubuntu Server
   * 10.04 LTS 64-bit
   * 10.10 64-bit
   * 11.04 64-bit
   * 11.10 64-bit
 * Apache 2.2.x
 * Java SE 1.6_31
 * Tomcat 7.0.26
 * Railo 3.3.1.000

## The Latest Version
The latest version of this script can always be found at the Github project page which is located at [https://github.com/talltroym/Railo-Ubuntu-Installer-Script](https://github.com/tdm00/Railo-Ubuntu-Installer-Script)

Details of the latest version can be found on the Apache HTTP server project page under [http://httpd.apache.org/](http://httpd.apache.org/)

## Documentation
The file serves as the current central documentation for this script file.

## Installation
Once your Ubuntu Server is running, copy this file to the server
using one of the following methods:

 1. Copy and paste the contents of this file from your system to a text editor
 2. `scp setup-railo.sh <ubuntu-username>@<server ip>`
 3. `wget https://raw.github.com/tdm00/Railo-Ubuntu-Installer-Script/master/setup-railo.sh`


_Note:_ If you use wget you'll need to run `fromdos setup-railo.sh` on the file to convert the line endings.  You can install this program and run it using the following commands:

`sudo aptitude install tofrodos`

`fromdos setup-railo.sh`

Next you need to give the script execute privileges by doing:

`sudo chmod +x setup-railo.sh`

Last, execute the script by typing:

`sudo ./setup-railo.sh`

Once this script has completed, you should have a running copy of Railo on your system.  Open your Internet browser and point to the servers IP address or DNS name and you should see the sample CFML page with the current date and time.

## Licensing
This script is licensed under the Apache License, Version 2.0.  You can read this license at [http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0)
