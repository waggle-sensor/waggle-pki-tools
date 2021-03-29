#!/bin/bash -e

source "$(dirname "$0")/common.sh"

init_ca

for name in $*; do
    sign_upload_credentials "$name"
done
