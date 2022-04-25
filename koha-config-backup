#!/bin/bash

## This script is to enable or disable backup of config files in the Koha-conf.xml file.

# Prompt the user for the name of the  Koha instance for which you want to enable backups.
echo "Here's the list of your Koha instances:"
# List Koha instances on server
koha-list
echo
echo "Enter the name of your Koha instance:"

# Read the input and store in a variable
read instancename

# Replace the backup configuration file using sed
sudo sed -i 's%.*backup_conf_via_tools.*% <backup_conf_via_tools>1</backup_conf_via_tools>%' /etc/koha/sites/$instancename/koha-conf.xml


#!/bin/bash

## This script is to enable backup of condig file via tools in the koha-conf.xml file in /etc/koha/sites/$instancename/ using sed. This file must be chmod +x
while true; do
    read -p "Disable (d) or Enable (e) Backup via tools" de
        case $de in
        [Dd]* ) sudo sed -i 's%.*backup_conf_via_tools.*% <backup_conf_via_tools>0</backup_conf_via_tools>%' /etc/koha/sites/$instancename/koha-conf.xml; break;;
        [Ee]* ) sudo sed -i 's%.*backup_conf_via_tools.*% <backup_conf_via_tools>1</backup_conf_via_tools>%' /etc/koha/sites/$instancename/koha-conf.xml;break;;
                * ) echo "Please answer d or e.";;
     esac
done
sudo xmlstarlet sel -t -v 'yazgfs/config/backup_conf_via_tools' /etc/koha/sites/$instancename/koha-conf.xml;echo
