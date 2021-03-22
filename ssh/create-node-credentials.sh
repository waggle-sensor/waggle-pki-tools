#!/bin/bash

source "$(dirname "$0")/common.sh"

for name in $*; do
    sign_upload_credentials "$name"
done
