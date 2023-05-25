#!/bin/bash

set -euf -o pipefail

metadata="$1"

if [ ! -f "$metadata" ]
then
    echo "Metadata file $metadata does not exist; please provide as a CLI argument"
    exit 1
fi

if [ -d results ]
then
   echo "Previous introspection results exist; please clean up"
   exit 1
fi

script_base=$(dirname "${BASH_SOURCE[0]}")

source "$script_base/introspect_postgres.sh"
source "$script_base/introspect_remote.sh"

build_name="$script_base/results/introspection.json"

echo '{"backend_introspection":{' > "$build_name"

### write DB introspection

separator=''
for db in "$databases"
do
    echo "$separator"'"'"$db"'":{"pg":{"metadata":{"tables":' >> "$build_name"
    tail -n+2 "$script_base/results/pg/$db/tables.json"|head -n-1 |tr -d '\n'|jq 'map([.table_name,.info])' >> "$build_name"
    echo ',"functions":' >> "$build_name"
    tail -n+2 "$script_base/results/pg/$db/functions.json"|head -n-1 |tr -d '\n'|jq 'map([.function_name,.info])' >> "$build_name"
    echo ',"scalars":[]},"enum_values":[]}}' >> "$build_name"
    separator=','
done

echo '}' >> "$build_name"

### write RS introspection
echo ',"remotes":{' >> "$build_name"

separator=''
for rs in "$remotes"
do
    echo "\"$rs\":" >> "$build_name"
    cat "$script_base/results/remotes/$rs.json" >> "$build_name"
    echo "$separator" >> "$build_name"
    separator=','
done

echo '}' >> "$build_name"

### finish
echo '}' >> "$build_name"

jq . < "$build_name" 1>/dev/null && echo "Result looks good! See $script_base/results/introspection.json"
