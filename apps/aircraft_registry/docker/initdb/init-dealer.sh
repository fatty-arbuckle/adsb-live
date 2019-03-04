#!/bin/bash
set -e

file="/faa_data/DEALER.txt"
table="dealer"

echo "creating table $table from $file"

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
  \connect aircraft_registry
  CREATE TABLE public.${table}
  (
      certificate_number        character varying(100),
      ownership                 character varying(100),
      certificate_date          character varying(100),
      expiration_date           character varying(100),
      expiration_flag           character varying(100),
      certificate_issue_count   character varying(100),
      name                      character varying(100),
      street                    character varying(100),
      street2                   character varying(100),
      city                      character varying(100),
      state_abbrev              character varying(100),
      zip_code                  character varying(100),
      other_names_count         character varying(100),
      other_names_1             character varying(100),
      other_names_2             character varying(100),
      other_names_3             character varying(100),
      other_names_4             character varying(100),
      other_names_5             character varying(100),
      other_names_6             character varying(100),
      other_names_7             character varying(100),
      other_names_8             character varying(100),
      other_names_9             character varying(100),
      other_names_10            character varying(100),
      other_names_11            character varying(100),
      other_names_12            character varying(100),
      other_names_13            character varying(100),
      other_names_14            character varying(100),
      other_names_15            character varying(100),
      other_names_16            character varying(100),
      other_names_17            character varying(100),
      other_names_18            character varying(100),
      other_names_19            character varying(100),
      other_names_20            character varying(100),
      other_names_21            character varying(100),
      other_names_22            character varying(100),
      other_names_23            character varying(100),
      other_names_24            character varying(100),
      other_names_25            character varying(100),
      junk                      character varying(100)
  );
  \copy $table FROM '$file' delimiter ',' csv header
EOSQL
