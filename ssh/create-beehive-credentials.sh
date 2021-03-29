#!/bin/bash -e

source "$(dirname "$0")/common.sh"

init_ca
sign_host_credentials beehive-upload-server
