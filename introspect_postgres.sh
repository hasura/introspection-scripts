#!/bin/env sh

set -xeuf -o pipefail

url="$1"

domain=$(echo "$url" | awk -F/ '{print $3}')

dir="results/postgres"

mkdir -p "$dir"

psql "$@" -f pg_table_metadata.sql -o "$dir/tables.json" -A
psql "$@" -f pg_function_metadata.sql -o "$dir/functions.json" -A
