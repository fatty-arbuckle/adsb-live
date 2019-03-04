#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL1
    CREATE DATABASE aircraft_registry;
    GRANT ALL PRIVILEGES ON DATABASE aircraft_registry TO postgres;
    \connect aircraft_registry
EOSQL1
