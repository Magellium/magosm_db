#!/bin/bash

# Settings
set -e # Be sure we fail on error and output debugging information
trap 'echo "$0: error on line $LINENO"' ERR
#set -x # Print commands and their arguments as they are executed

# Config reading
here="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
. $here/../../conf/config

# source : https://github.com/springmeyer/up-to-date/blob/master/how_to.txt
# make sure osmososis/osm2pgsql are on your PATH
# cron does not inherit from your env
export PATH=/usr/bin/:$PATH

echo
echo "##############################################################################################################################################"
echo `date`
echo "##############################################################################################################################################"
echo

OSMOSIS_WORKING_DIR=$DOCKER_VOLUMES_BASE_DIR/$OSMOSIS_OSM2PGSQL_WORKING_DIR/updates

echo
echo ------------------------------------------------------
echo OSMOSIS_WORKING_DIR: $OSMOSIS_WORKING_DIR
echo

echo
echo ------------------------------------------------------
echo CHECK FOR A LOCK FILE TO AVOID CONCURRENT PROCESS
echo

# lock file
LOCK=$OSMOSIS_WORKING_DIR/keepup.lock

cd $OSMOSIS_WORKING_DIR
if [ -f $LOCK ]; then
  if [ "$(ps -p `cat $LOCK` | wc -l)" -gt 1 ]; then
	echo "Locked"
	exit 1
  else
	rm $LOCK
  fi
fi
echo $$ >$LOCK

echo
echo ------------------------------------------------------
echo REMOVE $OSMOSIS_WORKING_DIR/changes/changes.osc.gz if exists
echo

OSM_CHANGE=changes/changes.osc.gz
OSM_CHANGE_OLD=changes/changes_old.osc.gz
if [ -f "$OSM_CHANGE" ]
then
  mv $OSM_CHANGE $OSM_CHANGE_OLD
fi

echo
echo ------------------------------------------------------
echo DELETE FROM TABLES trigger_info_point/line/polygon
echo

psql -U $DBPG_USER_MAGOSM_USERNAME -d $DBPG_DATABASE_NAME << EOF
DELETE FROM trigger_info_point;
DELETE FROM trigger_info_line;
DELETE FROM trigger_info_polygon;
EOF

echo
echo ------------------------------------------------------
echo OSMOSIS: READ/SIMPLIFY/WRITE-XML-CHANGES to $OSM_CHANGE
echo


OSMOSIS_CMD="osmosis \
--read-replication-interval \
workingDirectory=. \
--simplify-change --write-xml-change $OSM_CHANGE"
echo $OSMOSIS_CMD
eval $OSMOSIS_CMD

echo
echo ------------------------------------------------------
echo OSM2PGSQL: append $OSM_CHANGE to database
echo

OSM2PGSQL_CMD="osm2pgsql \
--append \
$OSM2PGSQL_OPTS \
$OSM_CHANGE"
echo $OSM2PGSQL_CMD
eval $OSM2PGSQL_CMD

echo
echo ------------------------------------------------------
echo Remove $LOCK
echo

rm $LOCK
