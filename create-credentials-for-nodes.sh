#!/bin/bash
set -e

cd $(dirname "${0}")

for nodeID in $*; do
    name="node-$nodeID"

    echo "creating credentials for $name"

    (cd tls; ./create-node-credentials.sh "$name")
    (cd ssh; ./create-node-credentials.sh "$name")
    
    mkdir -p credentials
    chmod 700 credentials

    (
    cat tls/configmaps/beehive-ca-certificate.yaml
    echo '---'
    cat "tls/secrets/$name-wes-beehive-rabbitmq-tls.yaml"
    echo '---'
    cat ssh/configmaps/beehive-ssh-ca.yaml
    echo '---'
    cat "ssh/secrets/$name-wes-beehive-upload-ssh-key.yaml"
    ) > "credentials/$name.yaml"

    chmod 600 "credentials/$name.yaml"

    echo "done"
done
