#!/bin/bash

source "$(dirname "$0")/common.sh"

init_ca

for nodeID in $*; do
    sign_credentials "node-$nodeID"
done
