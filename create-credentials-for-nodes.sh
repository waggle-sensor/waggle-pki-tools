#!/bin/bash -e

for nodeID in $*; do
    name="node-$nodeID"

    echo "creating credentials for $name"

    (cd tls; ./create-node-credentials.sh "$name")
    (cd ssh; ./create-node-credentials.sh "$name")
    
    mkdir -p credentials

    (
    cat tls/configmaps/beehive-ca-certificate.yaml
    echo '---'
    cat "tls/secrets/$name-wes-beehive-rabbitmq-tls.yaml"
    echo '---'
    cat ssh/configmaps/beehive-ssh-ca.yaml
    echo '---'
    cat "ssh/secrets/$name-wes-beehive-upload-ssh-key.yaml"
    ) > "credentials/$name.yaml"

    echo "done"
done
