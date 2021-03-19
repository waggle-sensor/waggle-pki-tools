#!/bin/bash

source "$(dirname $0)/common.sh"

init_ca

# create server credentials
sign_credentials beehive-rabbitmq

# create client credentials
sign_credentials beehive-message-logger
sign_credentials beehive-influxdb-loader
sign_credentials beehive-message-generator

# TODO consider approach for easier management of client services
# within cluster. this may be:
# 1. have intermediate ca used by beehive just for its own services
# 2. use username / random passwords in rabbitmq
