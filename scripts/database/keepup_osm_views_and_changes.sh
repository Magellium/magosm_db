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


echo
echo ------------------------------------------------------
echo Remove changes older than 30 days
echo

psql -U $DBPG_USER_MAGOSM_USERNAME -d $DBPG_DATABASE_NAME << EOF
DELETE FROM changes_analysis_point WHERE timestamp < current_date - 30;
DELETE FROM changes_analysis_line WHERE timestamp < current_date - 30;
DELETE FROM changes_analysis_polygon WHERE timestamp < current_date - 30;
EOF

echo
echo ------------------------------------------------------
echo Add changes for this iteration
echo

psql -U $DBPG_USER_MAGOSM_USERNAME -d $DBPG_DATABASE_NAME << EOF
SELECT changes_analysis(); 
EOF