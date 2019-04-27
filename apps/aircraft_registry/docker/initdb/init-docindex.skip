#!/bin/bash
set -e

file="/faa_data/DOCINDEX.txt"
table="document_index"

echo "creating table $table from $file"

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
  \connect aircraft_registry
  CREATE TABLE public.${table}
  (
    type_collateral character varying(100),
    collateral character varying(100),
    party character varying(100),
    doc_id character varying(100),
    drdate character varying(100),
    processing_date character varying(100),
    corr_date character varying(100),
    corr_id character varying(100),
    serial_id character varying(100),
    junk character varying(100)
  );

  \copy $table FROM '$file' delimiter ',' csv header
EOSQL
