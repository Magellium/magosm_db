#!/bin/bash

# Settings
set -e # Be sure we fail on error and output debugging information
trap 'echo "$0: error on line $LINENO"' ERR
#set -x # Print commands and their arguments as they are executed

# Config reading
here="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
. $here/../../conf/config
export PATH=/usr/bin/:$PATH

echo
echo "##############################################################################################################################################"
echo `date`
echo "##############################################################################################################################################"
echo

echo
echo ------------------------------------------------------
echo RefreshAllMaterializedViews
echo

psql -U $DBPG_USER_MAGOSM_USERNAME -d $DBPG_DATABASE_NAME << EOF
SELECT RefreshAllMaterializedViews('$DBPG_SCHEMA_MAGOSM_NAME');
EOF
