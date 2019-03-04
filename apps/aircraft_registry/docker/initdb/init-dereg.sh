#!/bin/bash
set -e

file="/faa_data/DEREG.txt"
table="deregistered"

echo "creating table $table from $file"

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
  \connect aircraft_registry
  CREATE TABLE public.${table}
  (
    n_number character varying(100),
    serial_number character varying(100),
    mfr_mdl_code character varying(100),
    status_code character varying(100),
    name character varying(100),
    street_mail character varying(100),
    street2_mail character varying(100),
    city_mail character varying(100),
    state_abbrev_mail character varying(100),
    zip_code_mail character varying(100),
    eng_mfr_mdl character varying(100),
    year_mfr character varying(100),
    certification character varying(100),
    region character varying(100),
    county_mail character varying(100),
    country_mail character varying(100),
    air_worth_date character varying(100),
    cancel_date character varying(100),
    mode_s_code character varying(100),
    indicator_group character varying(100),
    exp_country character varying(100),
    last_act_date character varying(100),
    cert_issue_date character varying(100),
    street_physical character varying(100),
    street2_physical character varying(100),
    city_physical character varying(100),
    state_abbrev_physical character varying(100),
    zip_code_physical character varying(100),
    county_physical character varying(100),
    country_physical character varying(100),
    other_names_1_ character varying(100),
    other_names_2_ character varying(100),
    other_names_3_ character varying(100),
    other_names_4_ character varying(100),
    other_names_5_ character varying(100),
    kit_mfr character varying(100),
    kit_model character varying(100),
    mode_s_code_hex character varying(100),
    junk character varying(100)
  );

  \copy $table FROM '$file' delimiter ',' csv header
EOSQL
