#!/bin/bash
set -e

(cd tls && ./create-beehive-credentials.sh)
(cd ssh && ./create-beehive-credentials.sh)

mkdir -p credentials
chmod 700 credentials

(
cat tls/configmaps/beehive-ca-certificate.yaml
echo '---'
cat tls/secrets/rabbitmq-tls-secret.yaml
echo '---'
cat ssh/configmaps/beehive-ssh-ca.yaml
echo '---'
cat ssh/secrets/upload-server-ssh-host-key.yaml
) > credentials/beehive.yaml

chmod 600 credentials/beehive.yaml
