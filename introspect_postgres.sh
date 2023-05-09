#!/bin/bash

set -xeuf -o pipefail

dir="results/postgres"

mkdir -p "$dir"

psql "$@" -f pg_table_metadata.sql -o "$dir/tables.json" -A
psql "$@" -f pg_function_metadata.sql -o "$dir/functions.json" -A
