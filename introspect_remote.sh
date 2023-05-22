#!/bin/bash

set -xeuf -o pipefail

mkdir -p results/remotes

url="$1"

domain=$(echo "$url" | awk -F/ '{print $3}')
filename="results/remotes/$domain.json"

if [ -f "$filename" ]
then
    echo "ERROR: Remote Schema introspection $filename already exists; please rename it"
    exit 1
fi

curl "$@" \
  -X POST \
  -H 'content-type: application/json' \
  --data-binary "@remote-schema.json" \
  -o "$filename"
