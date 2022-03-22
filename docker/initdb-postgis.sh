#!/bin/sh

set -eu

# Perform all actions as $POSTGRES_USER
export PGUSER="$POSTGRES_USER"

echo "Install PostGIS extensions to '$POSTGRES_DB'"
"${psql[@]}" --dbname="$POSTGRES_DB" <<-'EOSQL'
    CREATE EXTENSION IF NOT EXISTS postgis;
    CREATE EXTENSION IF NOT EXISTS hstore;
EOSQL
