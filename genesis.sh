#!/bin/bash

# Sometimes you mess things up so much you need to start all over again. 
# This script purges the AMP in LAMP, koha-common, and additional software/dependencies to return the server to a barebones state.
# Use carefully, this will wipe out ALL your data. I'd definitely advise against running this script on a production server :)

# Stop Apache
sudo systemctl stop apache2.service

# Stop MySQL/MariaDB
sudo systemctl stop mysql.service

# Stop koha-common
sudo systemctl stop koha-common

# Stop php
sudo systemctl stop phpmyadmin*

# Purge Apache
sudo apt remove --purge apache2*

# Purge Mysql
sudo apt remove --purge  mysql-*

# Purge Koha-common
sudo apt remove --purge koha-common

# Purge php
sudo apt remove --purge phpmyadmin*

# Clean residual files. Deletes all directories

# Remove koha-common
sudo rm -rf /var/spool/koha /var/log/koha /var/lock/koha /var/lib/koha /etc/koha/ /var/cache/koha

# Remove apache2
sudo rm -rf /etc/apache2/

# Remove mysql
sudo rm -rf /etc/mysql

# Clean orphaned  packages
sudo  apt autoremove
sudo apt autoclean
