#!/bin/bash

source "$(dirname "$0")/common.sh"

for nodeID in $*; do
    sign_credentials "node-$nodeID"
done
