#!/bin/bash

# Settings
set -e # Be sure we fail on error and output debugging information
trap 'echo "$0: error on line $LINENO"' ERR

echo
echo ------------------------------------------------------
echo Set PGSQL settings
echo

# postgres settings (compatible with postgres 12): 
# - uncomment and set wanted parameters
# - [help] the command `sed -i -e"s/^shared_buffers = 128MB.*$/shared_buffers = 4GB/" ${PGDATA}/postgresql.conf`
#   will update "shared_buffers" parameter from "128MB" (default) to "4GB" in postgresql.conf file

set -x # Print commands and their arguments as they are executed
sed -i -e"s/^shared_buffers = 128MB.*$/shared_buffers = 512MB/" ${PGDATA}/postgresql.conf
sed -i -e"s/^#work_mem = 4MB.*$/work_mem = 64MB/" ${PGDATA}/postgresql.conf
sed -i -e"s/^#maintenance_work_mem = 64MB.*$/maintenance_work_mem = 1024MB/" ${PGDATA}/postgresql.conf
sed -i -e"s/^#wal_buffers = -1.*$/wal_buffers = -1/" ${PGDATA}/postgresql.conf
sed -i -e"s/^min_wal_size = 80MB.*$/min_wal_size = 1GB/" ${PGDATA}/postgresql.conf
sed -i -e"s/^max_wal_size = 1GB.*$/max_wal_size = 2GB/" ${PGDATA}/postgresql.conf
sed -i -e"s/^#checkpoint_completion_target = 0.5.*$/checkpoint_completion_target = 0.9/" ${PGDATA}/postgresql.conf
sed -i -e"s/^#effective_cache_size = 4GB.*$/effective_cache_size = 23040MB/" ${PGDATA}/postgresql.conf
sed -i -e"s/^#logging_collector = off.*$/logging_collector = on/" ${PGDATA}/postgresql.conf
sed -i -e"s/^#log_directory = 'log'.*$/log_directory = 'log'/" ${PGDATA}/postgresql.conf
sed -i -e"s/^#log_filename = 'postgresql-%Y-%m-%d_%H%M%S.log'.*$/log_filename = 'postgresql-%a.log'/" ${PGDATA}/postgresql.conf
sed -i -e"s/^#log_truncate_on_rotation = off.*$/log_truncate_on_rotation = on/" ${PGDATA}/postgresql.conf
sed -i -e"s/^#log_rotation_age = 1d.*$/log_rotation_age = 1d/" ${PGDATA}/postgresql.conf
sed -i -e"s/^#log_rotation_size = 10MB.*$/log_rotation_size = 0/" ${PGDATA}/postgresql.conf
sed -i -e"s/^log_timezone = 'Etc\/UTC'.*$/log_timezone = 'UTC'/" ${PGDATA}/postgresql.conf
sed -i -e"s/^timezone = 'Etc\/UTC'.*$/timezone = 'UTC'/" ${PGDATA}/postgresql.conf