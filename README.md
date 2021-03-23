# Waggle PKI Tools

This repo contains tools for quickly generating credentials for both beehive and nodes. The primary tools are:

* `create-credentials-for-beehive.sh`. This will setup a CA if one doesn't exist and create a `credentials/beehive.yaml` file containing Kubernetes resources for the TLS / SSH CAs and credentials for RabbitMQ and upload services.
* `create-credentials-for-nodes.sh nodeID`. This will setup a CA if one doesn't exist and create a `credentials/node-nodeID.yaml` file containing Kubernetes resources for the TLS / SSH CAs and credentials for the shovels and uploader.

## Important Files

* `(tls|ssh)/ca/*`. All critical files related to the TLS / SSH CA. These _must be kept private_ and can be backed up and can be restored as needed.
* `credentials/*.yaml`. These are "Kubernetes ready" beehive and node credential bundles. These _must be kept private_.
