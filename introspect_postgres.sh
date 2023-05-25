#!/bin/bash

set -euf -o pipefail

metadata="$1"

script_base=$(dirname "${BASH_SOURCE[0]}")

basedir="$script_base/results/pg"

if [ -d "$basedir" ]
then
    echo "ERROR: Postgres introspection directory $basedir already exists; please rename it"
    exit 1
fi

databases_urls=$(jq '.metadata.sources|map("\(.name) " + $ENV."\(.configuration.connection_info.database_url.from_env)" )|.[]' "$metadata" -r)
echo "Detected $(wc -l <<< "$databases_urls") PG database(s) in the Metadata, starting introspection..."
databases=()
while read -r line
do
    words=($line)
    db_name=${words[0]}
    db_url=${words[1]}
    echo "Introspecting DB $db_name..."
    dir="$basedir/$db_name"
    mkdir -p "$dir"
    psql "$db_url" -f "$script_base/pg_table_metadata.sql" -o "$dir/tables.json" -A
    psql "$db_url" -f "$script_base/pg_function_metadata.sql" -o "$dir/functions.json" -A
    echo "Introspection stored in $dir/"
    databases+=("$db_name")
done <<< "$databases_urls"
