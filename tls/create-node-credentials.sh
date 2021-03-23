#!/bin/bash

source "$(dirname "$0")/common.sh"

init_ca

for name in $*; do
    sign_wes_rabbitmq_credentials "$name"
done
