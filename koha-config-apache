#!/bin/bash

# This script automatically configures the Apache config in /etc/apache2/sites-enabled/$instancename.conf after your Koha instance has been installed

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
