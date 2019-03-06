#!/bin/bash
set -e

file="/faa_data/ACFTREF.txt"
table="aircraft_reference"

echo "creating table $table from $file"

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
  \connect aircraft_registry
  CREATE TABLE public.${table}
  (
      code            character varying(100) primary key,
      mfr             character varying(100),
      model           character varying(100),
      type_acft       character varying(100),
      type_eng        character varying(100),
      ac_cat          character varying(100),
      build_cert_ind  character varying(100),
      no_eng          character varying(100),
      no_seats        character varying(100),
      ac_weight       character varying(100),
      speed           character varying(100),
      junk            character varying(100)
  );

  \copy $table FROM '$file' delimiter ',' csv header
EOSQL
