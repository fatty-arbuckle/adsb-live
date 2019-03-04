#!/bin/bash
set -e

file="/faa_data/MASTER.txt"
table="master"

echo "creating table $table from $file"

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
  \connect aircraft_registry
  CREATE TABLE public.${table}
  (
    n_number          character varying(100),
    serial_number     character varying(100),
    mfr_mdl_code      character varying(100),
    eng_mfr_mdl       character varying(100),
    year_mfr          character varying(100),
    type_registrant   character varying(100),
    name              character varying(100),
    street            character varying(100),
    street2           character varying(100),
    city              character varying(100),
    state             character varying(100),
    zip_code          character varying(100),
    region            character varying(100),
    county            character varying(100),
    country           character varying(100),
    last_action_date  character varying(100),
    cert_issue_date   character varying(100),
    certification     character varying(100),
    type_aircraft     character varying(100),
    type_engine       character varying(100),
    status_code       character varying(100),
    mode_s_code       character varying(100),
    fract_owner       character varying(100),
    air_worth_date    character varying(100),
    other_names_1_    character varying(100),
    other_names_2_    character varying(100),
    other_names_3_    character varying(100),
    other_names_4_    character varying(100),
    other_names_5_    character varying(100),
    expiration_date   character varying(100),
    unique_id         character varying(100),
    kit_mfr           character varying(100),
    kit_model         character varying(100),
    mode_s_code_hex   character varying(100),
    junk              character varying(100)
  );

  \copy $table FROM '$file' delimiter ',' csv header

  UPDATE $table SET mode_s_code_hex = trim(mode_s_code_hex);
EOSQL
