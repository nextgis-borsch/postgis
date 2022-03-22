#!/bin/sh

set -eu

# Perform all actions as $POSTGRES_USER
export PGUSER="$POSTGRES_USER"

POSTGIS_VERSION="${POSTGIS_VERSION%%+*}"

echo "Updating PostGIS extensions '$POSTGRES_DB' to $POSTGIS_VERSION"
psql --dbname="$POSTGRES_DB" -c "
    -- Upgrade PostGIS (includes raster)
    CREATE EXTENSION IF NOT EXISTS postgis VERSION '$POSTGIS_VERSION';
    ALTER EXTENSION postgis  UPDATE TO '$POSTGIS_VERSION';
"
