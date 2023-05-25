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


source introspect_postgres.sh
source introspect_remote.sh

echo '{"backend_introspection":{' > results/introspection.json

### write DB introspection

separator=''
for db in "$databases"
do
    echo "$separator"'"'"$db"'":{"pg":{"metadata":{"tables":' >> results/introspection.json
    tail -n+2 "results/pg/$db/tables.json"|head -n-1 |tr -d '\n'|jq 'map([.table_name,.info])' >> results/introspection.json
    echo ',"functions":' >> results/introspection.json
    tail -n+2 "results/pg/$db/functions.json"|head -n-1 |tr -d '\n'|jq 'map([.function_name,.info])' >> results/introspection.json
    echo ',"scalars":[]},"enum_values":[]}}' >> results/introspection.json
    separator=','
done

echo '}' >> results/introspection.json

### write RS introspection
echo ',"remotes":{' >> results/introspection.json

separator=''
for rs in "$remotes"
do
    echo "\"$rs\":" >> results/introspection.json
    cat "results/remotes/$rs.json" >> results/introspection.json
    echo "$separator" >> results/introspection.json
    separator=','
done

echo '}' >> results/introspection.json

### finish
echo '}' >> results/introspection.json

jq . < results/introspection.json 1>/dev/null && echo "Result looks good! See results/introspection.json"
