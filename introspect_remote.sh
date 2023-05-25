#!/bin/bash

set -euf -o pipefail

metadata="$1"

script_base=$(dirname "${BASH_SOURCE[0]}")

basedir="$script_base/results/remotes"

if [ -d "$basedir" ]
then
    echo "ERROR: Previous remote schema introspection results exist in $basedir; please clean up"
    exit 1
fi

mkdir -p "$basedir"

num_remotes=$(jq '.metadata.remote_schemas|length' < "$metadata")
echo "Detected $num_remotes remote schemas in the Metadata, starting introspection..."

remotes=()
for i in $(seq 1 "$num_remotes")
do
    remote_name=$(jq ".metadata.remote_schemas[$i-1].name" -r < "$metadata")
    filename="$basedir/$remote_name.json"
    echo "Introspecting remote $i called $remote_name..."
    url=$(jq ".metadata.remote_schemas[$i-1].definition.url" -r < "$metadata")
    curl_headers_list=$(jq ".metadata.remote_schemas[$i-1].definition.headers|map(\"\(.name): \(.value)\")|.[]" -rc < "$metadata")
    curl_headers=()
    while read -r line
    do
        curl_headers+=("-H")
        curl_headers+=("$line")
    done <<< "$curl_headers_list"

    curl "$url" \
         -q \
         -X POST \
         -H 'content-type: application/json' \
         --data-binary "@$script_base/remote-schema.json" \
         -o "$filename" \
         "${curl_headers[@]}"
    jq . < "$filename" > /dev/null || (echo "ERROR: Syntax error in fetched introspection" && exit 1)
    jq 'error(.error)' < "$filename"
    echo "Introspection stored at $filename"
    remotes+=("$remote_name")
done
