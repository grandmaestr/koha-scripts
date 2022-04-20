#!/bin/bash

# This script installs koha-common and  dependencies on a bare-bones Ubuntu server.
# I've tested this on Ubuntu Server 20.04LTS but it should work on other Debian distros. 
# You will need to configure Apache config files (/etc/apache2/sites-enabled/)
# You can copy and paste this script onto your server and make it executable by running "chmod a+x /path/to/file_name"
# To run the script, simply go to "/path/to/file_name" or if it's in your home directory, run "~/file_name" in the CLI.
# This script is interactive, so you'll be prompted for input at various stages.
# You can modify or use this script however you like but I'd really appreciate it if you give me a shout out or attribution if you post it elsewhere :)

# Add a Koha Community Repository
echo deb http://debian.koha-community.org/koha stable main | sudo tee /etc/apt/sources.list.d/koha.list

# Add the key in gpg.asc to your APT trusted keys to avoid warning messages on installation:
wget -O- https://debian.koha-community.org/koha/gpg.asc | sudo apt-key add -

# Update and upgrade Ubuntu
sudo apt update 
sudo apt upgrade
sudo apt clean

# Install Apache web server
sudo apt install apache2

# Enable the Apache mod_rewrite modules. The following commands enable Apache to create the configuration files.
sudo a2enmod rewrite
sudo a2enmod cgi
sudo systemctl restart apache2.service

# Download and install the latest Koha release
sudo apt install koha-common

# Install  MariaDB or MySQL
sudo apt install mysql-server

# Secure MySQL. You will recieve a number of prompts. This will ask if you want to configure the VALIDATE PASSWORD PLUGIN. It is best to answer No.
# Note: Enabling this feature is something of a judgment call.
# If enabled, passwords which don’t match the specified criteria will be rejected by MySQL with an error.
# This will cause issues if you use a weak password in conjunction with software which automatically configures MySQL user credentials, such as the Ubuntu packages for phpMyAdmin.
# It is safe to leave validation disabled, but you should always use strong, unique passwords for database credentials.
sudo mysql_secure_installation

# Install PHP. PHP is the component of your setup that will process code to display dynamic content.
# It can run scripts, connect to your MySQL databases to get information, and hand the processed content over to your web server so that it can display the results to your visitors.
sudo apt install php libapache2-mod-php php-mysql

# Prompt the user for the name of your koha instance. Input something simple and easily distinguishable from other instances.
echo "Enter the name of your Koha instance:"

# Read the input and store in a variable
read instancename

# Create the instance
sudo koha-create --create-db $instancename
echo "You will need to configure your instance for name-based or ip installation. See /etc/apache2/sites-available/$instancename for more." 
sleep 2
# Enable your Koha instance
sudo a2enmod deflate
sudo a2ensite $instancename

# Check Apache for configuration errors
echo "If you come across any errors, go to /etc/apache2/sites-enabled/$instancename."
sleep 2
sudo apachectl configtest

# Restart Apache
sudo systemctl restart apache2

# Enable instance
sudo koha-enable $instancename
echo "The Koha instance $instancename has been successfully installed"

# Start Zebra
sudo koha-zebra --restart $instancename

# Enable Plack
sudo koha-plack --enable $instancename
sudo koha-plack --start $instancename

# Print  koha_$instance name
sudo koha-passwd $instancename
