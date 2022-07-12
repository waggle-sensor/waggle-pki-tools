# Waggle PKI Tools

This repo contains tools for quickly generating credentials for both beehive and nodes. The primary tools are:

```sh
./create-credentials-for-beehive.sh
```

This will setup a CA if one doesn't exist and create a `credentials/beehive.yaml` file containing Kubernetes resources for the TLS / SSH CAs and credentials for RabbitMQ and upload services.


```sh
./create-credentials-for-nodes.sh nodeID
```

This will setup a CA if one doesn't exist and create a `credentials/node-nodeID.yaml` file containing Kubernetes resources for the TLS / SSH CAs and credentials for the shovels and uploader.

## Important Files

* `(tls|ssh)/ca/*`. All critical files related to the TLS / SSH CA. These _must be kept private_ and can be backed up and can be restored as needed.
* `credentials/*.yaml`. These are beehive and node credential bundles. These _must be kept private_. These are "Kubernetes ready" so that a single `kubectl apply -f x.yaml` will bootstrap all credentials required by the target.

## Building and Running Docker container

```bash
docker build -t waggle/waggle-pki-tools .
```

```bash
docker run -ti -v `pwd`:/workdir waggle/waggle-pki-tools bash
```