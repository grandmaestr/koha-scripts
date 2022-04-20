#!/bin/bash

# This script installs a new instance on a LAMP server with koha-common already installed and configures Apache.
# I've tested this on Ubuntu Server 20.04LTS but it should work on other Debian distros. 
# You can copy and paste this script onto your server and make it executable by running "chmod a+x /path/to/file_name"
# To run the script, simply go to "/path/to/file_name" or if it's in your home directory, run "~/file_name" in the CLI.
# This script is interactive, so you'll be prompted for input at various stages.
# You can modify or use this script however you like but I'd really appreciate it if you give me a shout out or attribution if you post it elsewhere :)

# Prompt the user for the name of your koha instance. Input something simple and easily distinguishable from other instances.
echo "Enter the name of your Koha instance:"

# Read the input and store in a variable
read instancename

# Create the instance
sudo koha-create --create-db $instancename
echo "You will need to configure your instance for name-based or ip installation. See /etc/apache2/sites-available/$instancename for more." 
sleep 2
# Enable your Koha instance
sudo a2ensite $instancename

# Use sed to configure your ServerName for name-based installation.
# Prompt user to enter their OPAC domain/subdomain
echo
echo "Enter the your OPAC url only (Skip http:// or https://):"
read  opacurl
echo "Your OPAC url is: $opacurl"

# Replace ServerName with  OPAC url above
sudo sed -i "/ServerName $instancename.myDNSname.org/c\   ServerName $opacurl" /etc/apache2/sites-enabled/$instancename.conf

# Prompt user to enter their Staff URL
echo
echo "Enter the your Staff url only (Skip http:// or https://):"
read  staffurl
echo "Your Staff url is: $opacurl"

# Replace ServerName with  OPAC url above
sudo sed -i "/ServerName $instancename-intra.myDNSname.org/c\   ServerName $staffurl" /etc/apache2/sites-enabled/$instancename.conf


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

# Print koha_$instance password for the web-based installation. Username will be koha_$instancename
sudo koha-passwd $instancename
