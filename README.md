# magOSM database

Source code used for [magOSM](https://github.com/Magellium/magOSM) database:

* Osm2pgsql database daily updated with Osmosis
* PostgreSQL materialized views for each magOSM thematic
* PostgreSQL triggers/functions/tables to detect/analyse/store OSM data changes on Osm2pgsql updates

A config file lets you choose your country, OSM data provider and so on.

## Get source code and adapt configuration

* clone this repo (it will be mounted later as a `source` docker volume)
* go to root directory

```bash
cd ./magosm_db
```

* create your config files from default ones

```bash
cp ./conf/default ./conf/config
cp ./conf/postgres_settings_default.sh ./conf/postgres_settings.sh
```

* adapt `./conf/config` and `./docker/postgres_settings.sh` config files to suit your needs

## Installation

### Read configuration

```bash
. ./conf/config
```

### Check requirements

* run this script until there is no error. It will check if all requirements are fullfilled and tell you what to do if necessary

```bash
bash ./scripts/check_requirements.sh
```

### Build and run docker

```bash
sudo docker build --tag $DOCKER_BUILD_TAG docker
```

```bash
sudo docker run \
  --detach \
  --restart always \
  --env POSTGRES_PASSWORD=$DBPG_USER_POSTGRES_PWD \
  --volume $HOST_VOLUMES_BASE_DIR/$OSMOSIS_OSM2PGSQL_WORKING_DIR:$DOCKER_VOLUMES_BASE_DIR/$OSMOSIS_OSM2PGSQL_WORKING_DIR \
  --volume $HOST_VOLUMES_BASE_DIR/$PG_DATA_DIR:/var/lib/postgresql/data \
  --volume $HOST_VOLUMES_BASE_DIR/$OSM_PBF_FILES_DIR:$DOCKER_VOLUMES_BASE_DIR/$OSM_PBF_FILES_DIR \
  --volume $HOST_VOLUMES_BASE_DIR/$OSM2PGSQL_FLATNODE_DIR:$DOCKER_VOLUMES_BASE_DIR/$OSM2PGSQL_FLATNODE_DIR \
  --volume $(pwd)/:$DOCKER_VOLUMES_BASE_DIR/$SOURCE_DIR \
  --publish $DOCKER_HOST_PORT_TO_PUBLISH:5432 \
  --shm-size="256MB" \
  --name $DOCKER_NAME \
  $DOCKER_BUILD_TAG
```

### Set postgres settings

```bash
sudo docker exec $DOCKER_NAME bash $DOCKER_VOLUMES_BASE_DIR/$SOURCE_DIR/conf/postgres_settings.sh
# check your pg_hba.conf is correct
sudo cat $HOST_VOLUMES_BASE_DIR/$PG_DATA_DIR/pg_hba.conf
# you must restart your container to restart postgres service (needed for parameters which require a restart to update, as `shared_buffers`)
sudo docker stop $DOCKER_NAME
sudo docker start $DOCKER_NAME
# you can check that your postgresql.conf file has been correctly edited
sudo docker exec $DOCKER_NAME bash -c 'cat ${PGDATA}/postgresql.conf'
```

### Create postgres users and database

```bash
sudo docker exec $DOCKER_NAME bash $DOCKER_VOLUMES_BASE_DIR/$SOURCE_DIR/scripts/database/init_db.sh
```

### osm2pgsql initial import

```bash
# prepare command
CMD="osm2pgsql \
--create \
$OSM2PGSQL_OPTS \
$DOCKER_VOLUMES_BASE_DIR/$OSM_PBF_FILES_DIR/$OSM_LATEST_PBF_FILE_NAME"
# check it
echo $CMD
# run
nohup sudo sh -c "docker exec $DOCKER_NAME $CMD >> $HOST_VOLUMES_BASE_DIR/$OSMOSIS_OSM2PGSQL_LOG_DIR/osm2pgsql-create.log 2>&1" &
# check log file
tail -f -n 200 $HOST_VOLUMES_BASE_DIR/$OSMOSIS_OSM2PGSQL_LOG_DIR/osm2pgsql-create.log
```

### Create magOSM postgres views

```bash
sudo docker exec $DOCKER_NAME bash $DOCKER_VOLUMES_BASE_DIR/$SOURCE_DIR/scripts/database/init_views.sh
# look for errors
sudo docker exec $DOCKER_NAME sh -c 'grep ERR /tmp/*log.err'
```

### Create magOSM-change postgres triggers, functions and tables

```bash
sudo docker exec $DOCKER_NAME bash $DOCKER_VOLUMES_BASE_DIR/$SOURCE_DIR/scripts/database/init_magosm-change.sh
```

### Init Osmosis working directory

First check for a local state.txt file.
If you don't have one, this script will give you
some useful instructions at end.
If you have one, this script will print it for you.

```bash
bash ./scripts/database/check_osmosis_state_file.sh
```

Init Osmosis working directory

```bash
bash ./scripts/database/init_osmosis_working_dir.sh
```

### Try an osmosis/osm2pgsql update manually

```bash
# osmosis/osm2pgsql update
nohup sudo sh -c "docker exec $DOCKER_NAME bash $DOCKER_VOLUMES_BASE_DIR/$SOURCE_DIR/scripts/database/keepup_osm_db_and_changes.sh >> $HOST_VOLUMES_BASE_DIR/$OSMOSIS_OSM2PGSQL_LOG_DIR/keepup_osm_db_and_changes.log 2>&1" &
# check log file
tail -f -n 200 $HOST_VOLUMES_BASE_DIR/$OSMOSIS_OSM2PGSQL_LOG_DIR/keepup_osm_db_and_changes.log
# then check that your state.txt is one day further
cat $HOST_VOLUMES_BASE_DIR/$OSMOSIS_OSM2PGSQL_WORKING_DIR/updates/state.txt
```

```bash
# views and changes table update
nohup sudo sh -c "docker exec $DOCKER_NAME bash $DOCKER_VOLUMES_BASE_DIR/$SOURCE_DIR/scripts/database/keepup_osm_views.sh >> $HOST_VOLUMES_BASE_DIR/$OSMOSIS_OSM2PGSQL_LOG_DIR/keepup_osm_views.log 2>&1" &
# check log file
tail -f -n 200 $HOST_VOLUMES_BASE_DIR/$OSMOSIS_OSM2PGSQL_LOG_DIR/keepup_osm_views.log
```

### Deploy cron tasks on host to keep everything up-to-date

```bash
sudo bash -c "cat <<EOF > /etc/cron.d/keepup_docker-$DOCKER_NAME
# osmosis/osm2pgsql update
30 0 * * * root docker exec $DOCKER_NAME bash $DOCKER_VOLUMES_BASE_DIR/$SOURCE_DIR/scripts/database/keepup_osm_db_and_changes.sh > $HOST_VOLUMES_BASE_DIR/$OSMOSIS_OSM2PGSQL_LOG_DIR/keepup_osm_db_and_changes.log 2>&1 && docker exec $DOCKER_NAME bash $DOCKER_VOLUMES_BASE_DIR/$SOURCE_DIR/scripts/database/keepup_osm_views.sh > $HOST_VOLUMES_BASE_DIR/$OSMOSIS_OSM2PGSQL_LOG_DIR/keepup_osm_views.log 2>&1
EOF"
```

### Add logrotate files

```bash
sudo bash -c "cat <<'EOF' > /etc/logrotate.d/keepup_osm_db_and_changes_docker-$DOCKER_NAME
$HOST_VOLUMES_BASE_DIR/$OSMOSIS_OSM2PGSQL_LOG_DIR/keepup_osm_db_and_changes.log {
  daily
  rotate 7
  missingok
  nocompress
  notifempty
  create 0644 root root
}
EOF"
sudo bash -c "cat <<'EOF' > /etc/logrotate.d/keepup_osm_views_docker-$DOCKER_NAME
$HOST_VOLUMES_BASE_DIR/$OSMOSIS_OSM2PGSQL_LOG_DIR/keepup_osm_views.log {
  daily
  rotate 7
  missingok
  nocompress
  notifempty
  create 0644 root root
}
EOF"
```

## Reinitialization

```bash
# Remove docker instance
docker stop $DOCKER_NAME
docker rm $DOCKER_NAME
# + Remove shared volumes by yourself (use absolute path, do not use bash variables here)
```
