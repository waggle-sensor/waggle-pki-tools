#!/bin/bash -e

(cd tls && ./create-beehive-credentials.sh)
(cd ssh && ./create-beehive-credentials.sh)

mkdir -p credentials

(
cat tls/configmaps/beehive-ca-certificate.yaml
echo '---'
cat tls/secrets/beehive-rabbitmq-tls-secret.yaml
echo '---'
cat ssh/configmaps/beehive-ssh-ca.yaml
echo '---'
cat ssh/secrets/beehive-upload-server-ssh-host-key.yaml
) > credentials/beehive.yaml
