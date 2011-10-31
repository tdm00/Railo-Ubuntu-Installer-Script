#!/bin/bash

# Automated 64-bit Ubuntu Railo Application Server Setup
# Setup variables
TOMCAT_VERSION="7.0.22"
JAVA_MINOR_VERSION="29"
RAILO_VERSION="3.3.1.000"

# Configure the firewall
sudo ufw logging on
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 22/tcp
sudo ufw default deny
sudo ufw enable <<LimitString
y
LimitString


# Update the server with the latest updates
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get dist-upgrade -y


# Install Apache web server
sudo apt-get install apache2 -y
sudo a2enmod ssl
sudo a2enmod proxy
sudo a2enmod proxy_http
sudo a2enmod rewrite
sudo a2ensite default-ssl


# Configure Apache web server
LINENUMBER=`sudo grep -n "<\/VirtualHost>" /etc/apache2/sites-available/default | sed 's/:.*//'`
sudo sed -i "$LINENUMBER"i'\\tRewriteRule ^.*$ https:\/\/%{SERVER_NAME}%{REQUEST_URI} [L,R]' /etc/apache2/sites-available/default
sudo sed -i "$LINENUMBER"i'\\tRewriteCond %{SERVER_PORT} !^443$' /etc/apache2/sites-available/default
sudo sed -i "$LINENUMBER"i'\\tRewriteEngine on' /etc/apache2/sites-available/default
sudo sed -i "$LINENUMBER"i'\\tDirectoryIndex index.cfm index.cfml default.cfm default.cfml index.htm index.html' /etc/apache2/sites-available/default
LINENUMBER=`sudo grep -n "<\/VirtualHost>" /etc/apache2/sites-available/default-ssl | sed 's/:.*//'`
# Uncomment the following lines IF you want CFWheels rewrite support
#sudo sed -i "$LINENUMBER"i'\\tRewriteRule "^\/(.*)" http:\/\/127.0.0.1:8080\/rewrite.cfm\/$1 [P,QSA,L]' /etc/apache2/sites-available/default-ssl
#sudo sed -i "$LINENUMBER"i'\\tRewriteCond %{REQUEST_URI} !^.*\/(flex2gateway|jrunscripts|cfide|cfformgateway|railo-context|files|images|javascripts|miscellaneous|stylesheets|robots.txt|sitemap.xml|rewrite.cfm)($|\/.*$) [NC]' /etc/apache2/sites-available/default-ssl
#sudo sed -i "$LINENUMBER"i'\\tRewriteEngine On' /etc/apache2/sites-available/default-ssl
#sudo sed -i "$LINENUMBER"i'\\t#Setup CFWheels with URL Rewriting' /etc/apache2/sites-available/default-ssl
sudo sed -i "$LINENUMBER"i'\\t<\/Location>' /etc/apache2/sites-available/default-ssl
sudo sed -i "$LINENUMBER"i'\\t\tAllow from 192.168.0.0\/24' /etc/apache2/sites-available/default-ssl
sudo sed -i "$LINENUMBER"i'\\t\tAllow from 172.16.0.0\/12' /etc/apache2/sites-available/default-ssl
sudo sed -i "$LINENUMBER"i'\\t\tDeny from all' /etc/apache2/sites-available/default-ssl
sudo sed -i "$LINENUMBER"i'\\t\tOrder deny,allow' /etc/apache2/sites-available/default-ssl
sudo sed -i "$LINENUMBER"i'\\t<Location \/railo-context\/admin\/>' /etc/apache2/sites-available/default-ssl
sudo sed -i "$LINENUMBER"i'\\t#Deny access to admin except for local clients' /etc/apache2/sites-available/default-ssl
sudo sed -i "$LINENUMBER"i'\\t\tProxyPassReverse \/ http:\/\/127.0.0.1:8080\/' /etc/apache2/sites-available/default-ssl
sudo sed -i "$LINENUMBER"i'\\t\tProxyPassMatch ^\/(.+\.cf[cm])(\/.*)?$ http:\/\/127.0.0.1:8080\/$1' /etc/apache2/sites-available/default-ssl
sudo sed -i "$LINENUMBER"i'\\t#Proxy .cfm and cfc requests to Railo' /etc/apache2/sites-available/default-ssl
sudo sed -i "$LINENUMBER"i'\\tDirectoryIndex index.cfm index.cfml default.cfm default.cfml index.htm index.html' /etc/apache2/sites-available/default-ssl
sudo sed -i 's/Deny from all/Allow from all/' /etc/apache2/mods-available/proxy.conf

# Start Apache
sudo service apache2 restart


# Download and Install Java
wget http://download.oracle.com/otn-pub/java/jdk/6u$JAVA_MINOR_VERSION-b11/jdk-6u$JAVA_MINOR_VERSION-linux-x64.bin
sudo chmod +x jdk-6u$JAVA_MINOR_VERSION-linux-x64.bin
sudo ./jdk-6u$JAVA_MINOR_VERSION-linux-x64.bin <<LimitString
yes
LimitString
sudo rm -Rf jdk-6u$JAVA_MINOR_VERSION-linux-x64.bin
sudo mkdir -p /usr/local/java
sudo mv jdk1.6.0_$JAVA_MINOR_VERSION/ /usr/local/java
sudo rm /usr/local/java/latest
sudo ln -s /usr/local/java/jdk1.6.0_$JAVA_MINOR_VERSION /usr/local/java/latest
sudo sed -i 1i'JAVA_HOME="/usr/local/java/latest"' /etc/environment
sudo sed -i 2i'JRE_HOME="/usr/local/java/latest/jre"' /etc/environment
export JAVA_HOME="/usr/local/java/latest"
export JRE_HOME="/usr/local/java/latest/jre"
export PATH="$JAVA_HOME/bin:$PATH"
sudo rm /usr/local/bin/java
sudo ln -s /usr/local/java/latest/bin/java /usr/local/bin/java


# Download and Install Apache Tomcat server
sudo wget http://mirrors.axint.net/apache/tomcat/tomcat-7/v7.0.TOMCAT_VERSION/bin/apache-tomcat-7.0.TOMCAT_VERSION.tar.gz
sudo tar -xvzf apache-tomcat-$TOMCAT_VERSION.tar.gz
sudo mv apache-tomcat-$TOMCAT_VERSION /opt/tomcat
sudo rm -Rf apache-tomcat-$TOMCAT_VERSION.tar.gz


# Configure Apache Tomcat
sudo touch /opt/tomcat/bin/setenv.sh
echo 'JAVA_HOME="/usr/local/java/latest"' | sudo tee -a /opt/tomcat/bin/setenv.sh
echo 'JRE_HOME="/usr/local/java/latest/jre"' | sudo tee -a /opt/tomcat/bin/setenv.sh


# Remove the default Tomcat applications
sudo rm -Rf /opt/tomcat/webapps/docs
sudo rm -Rf /opt/tomcat/webapps/examples
sudo rm -Rf /opt/tomcat/webapps/host-manager
sudo rm -Rf /opt/tomcat/webapps/manager
sudo rm -Rf /opt/tomcat/webapps/ROOT


# Secure the Tomcat installation
sudo /usr/sbin/useradd --create-home --home-dir /opt/tomcat --shell /bin/bash tomcat
sudo usermod -a -G www-data tomcat
sudo chown -R tomcat:tomcat /opt/tomcat
sudo chmod -R go-w /opt/tomcat
sudo chmod -R ugo-rwx /opt/tomcat/conf
sudo chmod -R u+rwx /opt/tomcat/conf
sudo chmod -R ugo-rwx /opt/tomcat/temp
sudo chmod -R u+rwx /opt/tomcat/temp
sudo chmod -R ugo-rwx /opt/tomcat/logs
sudo chmod -R u+wx /opt/tomcat/logs


# Download and Install Railo
sudo wget http://www.getrailo.org/down.cfm?item=/railo/remote/download/$RAILO_VERSION/custom/all/railo-$RAILO_VERSION-jars.tar.gz -O railo-$RAILO_VERSION-jars.tar.gz
sudo tar -xvzf railo-$RAILO_VERSION-jars.tar.gz
sudo mv railo-$RAILO_VERSION-jars /opt/railo
sudo rm -Rf railo-$RAILO_VERSION-jars.tar.gz


# Configure Railo
sudo sed -i 's/shared.loader=/shared.loader=\/opt\/railo\/*.jar/' /opt/tomcat/conf/catalina.properties
LINENUMBER=`sudo grep -n "Built In Servlet Mappings" /opt/tomcat/conf/web.xml | sed 's/:.*//'`
sudo sed -i "$LINENUMBER"i'\\t</servlet>' /opt/tomcat/conf/web.xml
sudo sed -i "$LINENUMBER"i'\\t\t<load-on-startup>1</load-on-startup>' /opt/tomcat/conf/web.xml
sudo sed -i "$LINENUMBER"i'\\t\t</init-param>' /opt/tomcat/conf/web.xml
sudo sed -i "$LINENUMBER"i'\\t\t\t<description>Configuration directory</description>' /opt/tomcat/conf/web.xml
sudo sed -i "$LINENUMBER"i'\\t\t\t<param-value>{web-root-directory}/WEB-INF/railo/</param-value>' /opt/tomcat/conf/web.xml
sudo sed -i "$LINENUMBER"i'\\t\t\t<param-name>configuration</param-name>' /opt/tomcat/conf/web.xml
sudo sed -i "$LINENUMBER"i'\\t\t<init-param>' /opt/tomcat/conf/web.xml
sudo sed -i "$LINENUMBER"i'\\t\t<servlet-class>railo.loader.servlet.CFMLServlet</servlet-class>' /opt/tomcat/conf/web.xml
sudo sed -i "$LINENUMBER"i'\\t\t<servlet-name>CFMLServlet</servlet-name>' /opt/tomcat/conf/web.xml
sudo sed -i "$LINENUMBER"i'\\t<servlet>' /opt/tomcat/conf/web.xml

LINENUMBER=`sudo grep -n "Built In Filter Definitions" /opt/tomcat/conf/web.xml | sed 's/:.*//'`
# Uncomment the following lines IF you want CFWheels rewrite support
#sudo sed -i "$LINENUMBER"i'\\t</servlet-mapping>' /opt/tomcat/conf/web.xml
#sudo sed -i "$LINENUMBER"i'\\t\t<url-pattern>/rewrite.cfm/*</url-pattern>' /opt/tomcat/conf/web.xml
#sudo sed -i "$LINENUMBER"i'\\t\t<servlet-name>CFMLServlet</servlet-name>' /opt/tomcat/conf/web.xml
#sudo sed -i "$LINENUMBER"i'\\t<servlet-mapping>' /opt/tomcat/conf/web.xml
#sudo sed -i "$LINENUMBER"i'\\t</servlet-mapping>' /opt/tomcat/conf/web.xml
#sudo sed -i "$LINENUMBER"i'\\t\t<url-pattern>/index.cfm/*</url-pattern>' /opt/tomcat/conf/web.xml
#sudo sed -i "$LINENUMBER"i'\\t\t<servlet-name>CFMLServlet</servlet-name>' /opt/tomcat/conf/web.xml
#sudo sed -i "$LINENUMBER"i'\\t<servlet-mapping>' /opt/tomcat/conf/web.xml
sudo sed -i "$LINENUMBER"i'\\t</servlet-mapping>' /opt/tomcat/conf/web.xml
sudo sed -i "$LINENUMBER"i'\\t\t<url-pattern>*.cfc</url-pattern>' /opt/tomcat/conf/web.xml
sudo sed -i "$LINENUMBER"i'\\t\t<servlet-name>CFMLServlet</servlet-name>' /opt/tomcat/conf/web.xml
sudo sed -i "$LINENUMBER"i'\\t<servlet-mapping>' /opt/tomcat/conf/web.xml
sudo sed -i "$LINENUMBER"i'\\t</servlet-mapping>' /opt/tomcat/conf/web.xml
sudo sed -i "$LINENUMBER"i'\\t\t<url-pattern>*.cfml</url-pattern>' /opt/tomcat/conf/web.xml
sudo sed -i "$LINENUMBER"i'\\t\t<servlet-name>CFMLServlet</servlet-name>' /opt/tomcat/conf/web.xml
sudo sed -i "$LINENUMBER"i'\\t<servlet-mapping>' /opt/tomcat/conf/web.xml
sudo sed -i "$LINENUMBER"i'\\t</servlet-mapping>' /opt/tomcat/conf/web.xml
sudo sed -i "$LINENUMBER"i'\\t\t<url-pattern>*.cfm</url-pattern>' /opt/tomcat/conf/web.xml
sudo sed -i "$LINENUMBER"i'\\t\t<servlet-name>CFMLServlet</servlet-name>' /opt/tomcat/conf/web.xml
sudo sed -i "$LINENUMBER"i'\\t<servlet-mapping>' /opt/tomcat/conf/web.xml
LINENUMBER=`sudo grep -n "<\/welcome-file-list>" /opt/tomcat/conf/web.xml | sed 's/:.*//'`
sudo sed -i "$LINENUMBER"i'\\t<welcome-file>index.cfm</welcome-file>' /opt/tomcat/conf/web.xml
sudo sed -i "$LINENUMBER"i'\\t<welcome-file>index.cfml</welcome-file>' /opt/tomcat/conf/web.xml
LINENUMBER=`sudo grep -n "SingleSignOn valve" /opt/tomcat/conf/server.xml | sed 's/:.*//'`
sudo sed -i "$LINENUMBER"i'\\t\t<Context path="" docBase="/var/www"/>' /opt/tomcat/conf/server.xml
sudo chown -R tomcat:tomcat /opt/railo 


# Start Tomcat, this creates the Railo server context
sudo -u tomcat /opt/tomcat/bin/startup.sh


# Wait for Tomcat to start and load the Railo engine
sleep 2m


# Shutdown Tomcat 
sudo -u tomcat /opt/tomcat/bin/shutdown.sh


# Wait for Tomcat to shutdown
sleep 1m


# Configure Tomcat to start with the system
echo '#!/bin/sh -e' > /etc/init.d/tomcat
echo '### BEGIN INIT INFO' >> /etc/init.d/tomcat
echo '# Provides: tomcat' >> /etc/init.d/tomcat
echo '# Required-Start: $local_fs $remote_fs $network $syslog ' >> /etc/init.d/tomcat
echo '# Required-Stop: $local_fs $remote_fs $network $syslog ' >> /etc/init.d/tomcat
echo '# Default-Start: 2 3 4 5 ' >> /etc/init.d/tomcat
echo '# Default-Stop: 0 1 6 ' >> /etc/init.d/tomcat
echo '# X-Interactive: true ' >> /etc/init.d/tomcat
echo '# Short-Description: Start/stop Tomcat as service ' >> /etc/init.d/tomcat
echo '### END INIT INFO ' >> /etc/init.d/tomcat
echo ' ' >> /etc/init.d/tomcat
echo '# setup the JAVA_HOME environment variable ' >> /etc/init.d/tomcat
echo 'export JAVA_HOME=/usr/local/java/latest ' >> /etc/init.d/tomcat
echo ' ' >> /etc/init.d/tomcat
echo 'ENV="env -i LANG=C PATH=/usr/local/bin:/usr/bin:/bin" ' >> /etc/init.d/tomcat
echo ' ' >> /etc/init.d/tomcat
echo '#set -e ' >> /etc/init.d/tomcat
echo ' ' >> /etc/init.d/tomcat
echo '#. /lib/lsb/init-functions ' >> /etc/init.d/tomcat
echo ' ' >> /etc/init.d/tomcat
echo '#test -f /etc/default/rcS && . /etc/default/rcS ' >> /etc/init.d/tomcat
echo ' ' >> /etc/init.d/tomcat
echo 'case $1 in ' >> /etc/init.d/tomcat
echo 'start) ' >> /etc/init.d/tomcat
echo 'exec sudo -u tomcat /opt/tomcat/bin/startup.sh ' >> /etc/init.d/tomcat
echo 'echo ' >> /etc/init.d/tomcat
echo ';; ' >> /etc/init.d/tomcat
echo 'stop) ' >> /etc/init.d/tomcat
echo 'exec sudo -u tomcat /opt/tomcat/bin/shutdown.sh ' >> /etc/init.d/tomcat
echo ';; ' >> /etc/init.d/tomcat
echo 'restart) ' >> /etc/init.d/tomcat
echo 'exec sudo -u tomcat /opt/tomcat/bin/shutdown.sh ' >> /etc/init.d/tomcat
echo 'sleep 30 ' >> /etc/init.d/tomcat
echo 'exec sudo -u tomcat /opt/tomcat/bin/startup.sh ' >> /etc/init.d/tomcat
echo 'sleep 30 ' >> /etc/init.d/tomcat
echo ';; ' >> /etc/init.d/tomcat
echo 'esac ' >> /etc/init.d/tomcat
echo 'exit 0 ' >> /etc/init.d/tomcat
cd /etc/init.d/
sudo chmod 755 tomcat
sudo update-rc.d tomcat defaults


# Setup default CFML page
sudo echo '<html>' > ~/index.cfm
sudo echo '<head>' >> ~/index.cfm
sudo echo '<title>' >> ~/index.cfm
sudo echo 'Welcome to Railo!' >> ~/index.cfm
sudo echo '</title>' >> ~/index.cfm
sudo echo '</head>' >> ~/index.cfm
sudo echo '<body>' >> ~/index.cfm
sudo echo '<h1>' >> ~/index.cfm
sudo echo 'Welcome to Railo running on Tomcat!' >> ~/index.cfm
sudo echo '</h1>' >> ~/index.cfm
sudo echo '<h2>' >> ~/index.cfm
sudo echo 'Current date and time are <cfoutput>#Now()#</cfoutput>' >> ~/index.cfm
sudo echo '</h2>' >> ~/index.cfm
sudo echo '</body>' >> ~/index.cfm
sudo echo '</html>' >> ~/index.cfm
sudo mv ~/index.cfm /var/www/index.cfm
sudo chown root /var/www/index.cfm
sudo chgrp tomcat /var/www/index.cfm


# Give Tomcat some time, for some reason it needs this, before it can create the /var/www/WEB-INF
sleep 2m


# Start Tomcat, this still doesn't create the Railo web context, not sure why
sudo -u tomcat /opt/tomcat/bin/startup.sh


# Wait for Tomcat to start and load the Railo engine
sleep 2m


# Shutdown Tomcat 
sudo -u tomcat /opt/tomcat/bin/shutdown.sh


# Wait for Tomcat to shutdown
sleep 1m


# Start Tomcat, this finally creates the Railo web context, not sure why it takes three starts
sudo -u tomcat /opt/tomcat/bin/startup.sh


# Wait for Tomcat to start and load the Railo engine
sleep 2m


# Install unzip utility
sudo apt-get install unzip -y


# Secure the Railo web
sudo mkdir -p /var/www/WEB-INF
sudo chown -hR tomcat /var/www/WEB-INF
sudo chgrp -hR tomcat /var/www 

