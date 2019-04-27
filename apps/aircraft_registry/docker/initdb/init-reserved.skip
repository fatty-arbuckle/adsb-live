#!/bin/bash
set -e

file="/faa_data/RESERVED.txt"
table="reserved"

echo "creating table $table from $file"

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
  \connect aircraft_registry
  CREATE TABLE public.${table}
  (
    n_number      character varying(100),
    registrant    character varying(100),
    street        character varying(100),
    street2       character varying(100),
    city          character varying(100),
    state         character varying(100),
    zip_code      character varying(100),
    rsv_date      character varying(100),
    tr            character varying(100),
    exp_date      character varying(100),
    n_num_chg     character varying(100),
    junk          character varying(100)
  );

  \copy $table FROM '$file' delimiter ',' csv header
EOSQL
