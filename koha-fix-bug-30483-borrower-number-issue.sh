#!/bin/bash

usage() {
  cat <<EOF
Usage: $(basename "$0") [koha_instance_name]

This script fixes the error encountered during the Koha upgrade to version 22.06.00.041:
Bug 30483 - Make issues.borrowernumber and issues.itemnumber NOT NULL
ERROR: {UNKNOWN}: DBI Exception: DBD::mysql::db do failed: Cannot change column 'borrowernumber': used in a foreign key constraint 'issues_ibfk_1' at /usr/share/koha/lib/C4/Installer.pm line 739

The script removes the foreign key constraints from the 'issues' table, updates the 'borrowernumber' and 'issues.itemnumber' columns to NOT NULL, and re-adds the foreign key constraints.

Arguments:
  koha_instance_name   The name of the Koha instance to fix the error for.

Requirements:
  - The script must be run as root or by a user with sudo privileges.
  - xmlstarlet must be installed.

Example:
  $(basename "$0") your_koha_instance_name
EOF
}

if [ "$#" -ne 1 ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
  usage
  exit 0
fi

koha_instance_name=$1

# Check if the script is being run as root or a user with sudo privileges
if [ "$(id -u)" != "0" ]; then
  echo "This script must be run as root or by a user with sudo privileges" >&2
  exit 1
fi

# Check if xmlstarlet is installed
if ! command -v xmlstarlet >/dev/null; then
  echo "xmlstarlet not found, please install it before running this script" >&2
  exit 1
fi

# Load Koha instance configuration
kohaconfig="/etc/koha/sites/$koha_instance_name/koha-conf.xml"
mysqlhost="$(sudo xmlstarlet sel -t -v 'yazgfs/config/hostname' "$kohaconfig")"
mysqldb="$(sudo xmlstarlet sel -t -v 'yazgfs/config/database' "$kohaconfig")"
mysqluser="$(sudo xmlstarlet sel -t -v 'yazgfs/config/user' "$kohaconfig")"
mysqlpass="$(sudo xmlstarlet sel -t -v 'yazgfs/config/pass' "$kohaconfig")"

# Connect to MySQL database and execute the required commands
mysql --host="$mysqlhost" --user="$mysqluser" --password="$mysqlpass" --database="$mysqldb" <<-EOF
-- Backup your database before running this script
-- Remove foreign key constraints
ALTER TABLE issues DROP FOREIGN KEY issues_ibfk_1;
ALTER TABLE issues DROP FOREIGN KEY issues_ibfk_2;

-- Update the borrowernumber and issues.itemnumber columns to NOT NULL
ALTER TABLE issues MODIFY borrowernumber INT NOT NULL;
ALTER TABLE issues MODIFY itemnumber INT NOT NULL;

-- Re-add the foreign key constraints
ALTER TABLE issues
ADD CONSTRAINT issues_ibfk_1
FOREIGN KEY (borrowernumber) REFERENCES borrowers (borrowernumber)
ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE issues
ADD CONSTRAINT issues_ibfk_2
FOREIGN KEY (itemnumber) REFERENCES items (itemnumber)
ON DELETE CASCADE ON UPDATE CASCADE;
EOF

echo "The columns borrowernumber and itemnumber have been updated to NOT NULL and foreign key constraints have been re-added."
