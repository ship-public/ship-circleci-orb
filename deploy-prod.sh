#!/usr/bin/env bash

if [ -z "$1" ]; then
  echo "Must pass sem-ver as first argument"
  exit 1
fi

set -euo pipefail

rm -rf build
mkdir build
circleci orb pack src > build/orb.yml

# This will fail if orb doesn't pass basic checks
circleci orb validate build/orb.yml

circleci orb publish ./build/orb.yml "ship-public/ship-orb@$1"
