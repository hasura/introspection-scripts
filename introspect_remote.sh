#!/bin/env sh

set -xeuf -o pipefail

mkdir -p results/remotes

url="$1"

domain=$(echo "$url" | awk -F/ '{print $3}')

curl "$@" \
  -X POST \
  -H 'content-type: application/json' \
  --data-binary "@remote-schema.json" \
  -o "results/remotes/$domain.json"
