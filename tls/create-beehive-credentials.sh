#!/bin/bash

source "$(dirname "$0")/common.sh"

init_ca
sign_credentials beehive-rabbitmq
