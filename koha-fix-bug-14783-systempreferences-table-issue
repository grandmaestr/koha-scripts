#!/bin/bash

set -euo pipefail

if [ "$(id -u)" != "0" ]; then
    echo "Error: This script must be run with sudo privileges."
    exit 1
fi

# Script to apply a patch to fix MySQL error in Koha
# Target file: /usr/share/koha/intranet/cgi-bin/installer/data/mysql/db_revs/220600064.pl

function print_help() {
    cat <<EOF
This script applies a patch to fix the following MySQL error in Koha:

ERROR 1093 (HY000): You can't specify target table 'systempreferences' for update in FROM clause

The error is related to Bug 32470 and Bug 14783.

Usage: $0 [--help]

Options:
  --help    Display this help message and exit
EOF
}

function print_usage() {
    echo "Usage: $0 [--help]"
}

if [ "$#" -gt 0 ] && [ "$1" == "--help" ]; then
    print_help
    exit 0
fi

if [ "$#" -gt 0 ]; then
    echo "Error: Invalid arguments"
    print_usage
    exit 1
fi

# Define the target file path
TARGET_FILE="/usr/share/koha/intranet/cgi-bin/installer/data/mysql/db_revs/220600064.pl"

# Check if the target file exists
if [ ! -f "$TARGET_FILE" ]; then
    echo "Error: Target file not found at $TARGET_FILE"
    exit 1
fi

# Apply the patch
patch "$TARGET_FILE" <<'EOF'
--- a/installer/data/mysql/db_revs/220600064.pl
+++ b/installer/data/mysql/db_revs/220600064.pl
@@ -14,11 +14,17 @@ return {

         say $out "Added new system preference 'OPACAllowUserToChangeBranch'";

+    my ($value) = $dbh->selectrow_array(q{
+            SELECT CASE WHEN value=1 THEN 'intransit' ELSE '' END
+            FROM systempreferences
+            WHERE variable='OPACInTransitHoldPickupLocationChange'
+        });
+
         $dbh->do(q{
             UPDATE systempreferences
-            SET value=(SELECT CASE WHEN value=1 THEN 'intransit' ELSE '' END FROM systempreferences WHERE variable='OPACInTransitHoldPickupLocationChange')
+            SET value=(?)
             WHERE variable='OPACAllowUserToChangeBranch'
-        });
+        }, undef, $value);

         $dbh->do(q{
             DELETE FROM systempreferences
EOF

echo "Patch applied successfully to $TARGET_FILE"
