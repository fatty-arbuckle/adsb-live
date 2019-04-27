#!/bin/bash
set -e

file="/faa_data/ENGINE.txt"
table="engine"

echo "creating table $table from $file"

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
  \connect aircraft_registry
  CREATE TABLE public.${table}
  (
    code character varying(100) primary key,
    mfr character varying(100),
    model character varying(100),
    type character varying(100),
    horsepower character varying(100),
    thrust character varying(100),
    junk character varying(100)
  );

  \copy $table FROM '$file' delimiter ',' csv header
EOSQL
