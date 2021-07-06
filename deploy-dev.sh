#!/usr/bin/env bash

set -euo pipefail

rm -rf build
mkdir build
circleci orb pack src > build/orb.yml

# This will fail if orb doesn't pass basic checks
circleci orb validate build/orb.yml

circleci orb publish ./build/orb.yml ship-public/ship-orb@dev:first
