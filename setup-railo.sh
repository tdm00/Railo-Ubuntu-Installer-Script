# Automated 32-bit Ubuntu Railo Application Server Setup
#

# Configure the firewall
sudo ufw logging on
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 64022/tcp
sudo ufw default deny
sudo ufw enable <<LimitString
y
LimitString


# Update the server with the latest updates
sudo apt-get update
sudo apt-get dist-upgrade -y


# Download and Install Java
wget http://download.oracle.com/otn-pub/java/jdk/6u26-b03/jdk-6u26-linux-i586.bin
sudo chmod +x jdk-6u26-linux-i586.bin
sudo ./jdk-6u26-linux-i586.bin <<LimitString
yes
LimitString
sudo rm -Rf jdk-6u26-linux-i586.bin
sudo mkdir -p /usr/local/java
sudo mv jdk1.6.0_26/ /usr/local/java
sudo rm /usr/local/java/latest
sudo ln -s /usr/local/java/jdk1.6.0_26 /usr/local/java/latest
sudo sed -i 1i'JAVA_HOME="/usr/local/java/latest"' /etc/environment
sudo sed -i 2i'JRE_HOME="/usr/local/java/latest/jre"' /etc/environment
echo 'PATH="$JAVA_HOME/bin:$PATH"' | sudo tee -a /etc/environment
export JAVA_HOME="/usr/local/java/latest"
export JRE_HOME="/usr/local/java/latest/jre"
export PATH="$JAVA_HOME/bin:$PATH"
sudo rm /usr/local/bin/java
sudo ln -s /usr/local/java/latest/bin/java /usr/local/bin/java


# Download and Install Apache Tomcat server
sudo wget http://mirror.candidhosting.com/pub/apache/tomcat/tomcat-7/v7.0.19/bin/apache-tomcat-7.0.19.tar.gz
sudo tar -xvzf apache-tomcat-7.0.19.tar.gz
sudo mv apache-tomcat-7.0.19 /opt/tomcat
sudo rm -Rf apache-tomcat-7.0.19.tar.gz


# Configure Apache Tomcat
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
sudo wget http://www.getrailo.org/down.cfm?item=/railo/remote/download/3.2.3.000/custom/all/railo-3.2.3.000-jars.tar.gz -O railo-3.2.3.000-jars.tar.gz
sudo tar -xvzf railo-3.2.3.000-jars.tar.gz
sudo mv railo-3.2.3.000-jars /opt/railo
sudo rm -Rf railo-3.2.3.000-jars.tar.gz


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


# Start Tomcat 
sudo -u tomcat /opt/tomcat/bin/startup.sh


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
sudo sed -i "$LINENUMBER"i'\\t\tAllow from 10.242.2.0\/24' /etc/apache2/sites-available/default-ssl
sudo sed -i "$LINENUMBER"i'\\t\tAllow from 172.16.4.0\/24' /etc/apache2/sites-available/default-ssl
sudo sed -i "$LINENUMBER"i'\\t\tDeny from all' /etc/apache2/sites-available/default-ssl
sudo sed -i "$LINENUMBER"i'\\t\tOrder deny,allow' /etc/apache2/sites-available/default-ssl
sudo sed -i "$LINENUMBER"i'\\t<Location \/railo-context\/>' /etc/apache2/sites-available/default-ssl
sudo sed -i "$LINENUMBER"i'\\t#Deny access to admin except for local clients' /etc/apache2/sites-available/default-ssl
sudo sed -i "$LINENUMBER"i'\\t\tProxyPassReverse \/ http:\/\/127.0.0.1:8080\/' /etc/apache2/sites-available/default-ssl
sudo sed -i "$LINENUMBER"i'\\t\tProxyPassMatch ^\/(.*\\.cfm)$ http:\/\/127.0.0.1:8080\/$1' /etc/apache2/sites-available/default-ssl
sudo sed -i "$LINENUMBER"i'\\t#Proxy .cfm requests to Railo' /etc/apache2/sites-available/default-ssl
sudo sed -i "$LINENUMBER"i'\\tDirectoryIndex index.cfm index.cfml default.cfm default.cfml index.htm index.html' /etc/apache2/sites-available/default-ssl
sudo sed -i 's/Deny from all/Allow from all/' /etc/apache2/mods-available/proxy.conf


# Start Apache
sudo service apache2 restart


# Secure the Railo web
sudo chown -hR tomcat /var/www/WEB-INF
sudo chgrp -hR tomcat /var/www 


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