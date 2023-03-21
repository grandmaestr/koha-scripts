#!/bin/bash

# Koha DBMS autoincrement fix script.
# This script is designed to be run on startup to ensure the Koha DBMS autoincrement issue is fixed.
# Actual script is courtesy of KohaAloha (https://github.com/KohaAloha/koha-mysql-init).

function usage() {
    echo "Usage: $0 [-h|--help]"
    echo "Fix the Koha DBMS autoincrement issue by updating the AUTO_INCREMENT values for various tables."
    echo "This script must be run as root or with sudo privileges."
    echo
    echo "Options:"
    echo "  -h, --help    Show this help message and exit."
    echo
}

function main() {
    if [[ $# -gt 0 ]]; then
        case "$1" in
            -h|--help)
                usage
                exit 0
                ;;
            *)
                echo "Unknown option: $1"
                usage
                exit 1
                ;;
        esac
    fi

    echo "Warning: This script will make changes to your system."
    read -p "Do you want to continue? [y/n]: " confirmation

    if [[ "$confirmation" == [yY] || "$confirmation" == [yY][eE][sS] ]]; then
        # Create koha-mysql-init.service file
        koha_mysql_init_service="/etc/systemd/system/koha-mysql-init.service"
        cat > "$koha_mysql_init_service" <<'EOF'
[Unit]
Description=Koha SQL init
After=mysql.service
Requires=mysql.service
PartOf=mysql.service

[Service]
ExecStartPre=/bin/sleep 10
ExecStart=/usr/local/bin/koha-autoincrement-fix.sh

[Install]
WantedBy=multi-user.target
WantedBy=mysql.service
EOF

        # Make sure the script is executable
        chmod +x "$0"

        # Copy the script to /usr/local/bin/
        cp "$0" /usr/local/bin/koha-autoincrement-fix.sh

        # Enable the koha-mysql-init service
        systemctl enable koha-mysql-init

        # Reload the systemd daemon
        systemctl daemon-reload

        # Restart mysql service to execute the init script
        systemctl restart mysql

        echo "Koha autoincrement fix setup completed successfully."
        echo "Please check the log files in /var/log/koha/instancename/ for any errors or warnings during the script execution."
    else
        echo "Aborted by user."
    fi
}

function koha_autoincrement_fix() {
    local instance="$1"

    koha_sql "$instance" <<'EOF'
SET @new_AI_borrowers = ( SELECT GREATEST( IFNULL( ( SELECT MAX(borrowernumber) FROM borrowers ), 0 ), IFNULL( ( SELECT MAX(borrowernumber) FROM deletedborrowers ), 0 ) ) + 1 );
SET @sql = CONCAT( 'ALTER TABLE borrowers AUTO_INCREMENT = ', @new_AI_borrowers );
PREPARE st FROM @sql;
EXECUTE st;

SET @new_AI_biblio = ( SELECT GREATEST( IFNULL( ( SELECT MAX(biblionumber) FROM biblio ), 0 ), IFNULL( ( SELECT MAX(biblionumber) FROM deletedbiblio ), 0 ) ) + 1 );
SET @sql = CONCAT( 'ALTER TABLE biblio AUTO_INCREMENT = ', @new_AI_biblio );
PREPARE st FROM @sql;
EXECUTE st;

SET @new_AI_biblioitems = ( SELECT GREATEST( IFNULL( ( SELECT MAX(biblioitemnumber) FROM biblioitems ), 0 ), IFNULL( ( SELECT MAX(biblioitemnumber) FROM deletedbiblioitems ), 0 ) ) + 1 );
SET @sql = CONCAT( 'ALTER TABLE biblioitems AUTO_INCREMENT = ', @new_AI_biblioitems );
PREPARE st FROM @sql;
EXECUTE st;

SET @new_AI_items = ( SELECT GREATEST( IFNULL( ( SELECT MAX(itemnumber) FROM items ), 0 ), IFNULL( ( SELECT MAX(itemnumber) FROM deleteditems ), 0 ) ) + 1 );
SET @sql = CONCAT( 'ALTER TABLE items AUTO_INCREMENT = ', @new_AI_items );
PREPARE st FROM @sql;
EXECUTE st;

SET @new_AI_issues = ( SELECT GREATEST( IFNULL( ( SELECT MAX(issue_id) FROM issues ), 0 ), IFNULL( ( SELECT MAX(issue_id) FROM old_issues ), 0 ) ) + 1 );
SET @sql = CONCAT( 'ALTER TABLE issues AUTO_INCREMENT = ', @new_AI_issues );
PREPARE st FROM @sql;
EXECUTE st;

SET @new_AI_reserves = ( SELECT GREATEST( IFNULL( ( SELECT MAX(reserve_id) FROM reserves ), 0 ), IFNULL( ( SELECT MAX(reserve_id) FROM old_reserves ), 0 ) ) + 1 );
SET @sql = CONCAT( 'ALTER TABLE reserves AUTO_INCREMENT = ', @new_AI_reserves );
PREPARE st FROM @sql;
EXECUTE st;
EOF
}

function koha_sql() {
    local instance="$1"
    koha-mysql "$instance"
}

main "$@"

