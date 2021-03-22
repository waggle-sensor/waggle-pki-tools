#!/bin/bash

source "$(dirname "$0")/common.sh"

for name in $*; do
    sign_wes_rabbitmq_credentials "$name"
done
