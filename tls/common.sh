#!/bin/bash
set -e

# detect correct base64 flags to use
if echo | base64 -b 0 &> /dev/null; then
  B64_FLAG="-b 0 -i"
else
  B64_FLAG="-w 0"
fi

b64() {
  base64 ${B64_FLAG} "$@"
}

CAKEYFILE="ca/cakey.pem"
CACERTFILE="ca/cacert.pem"

init_ca() {
    mkdir -p "$(dirname $CAKEYFILE)"
    chmod 700 "$(dirname $CAKEYFILE)"

    # create ca key / cert if key doesn't exist
    if ! test -e "$CAKEYFILE"; then
        openssl req \
            -x509 \
            -nodes \
            -newkey rsa:4096 \
            -keyout "$CAKEYFILE" \
            -out "$CACERTFILE" \
            -sha256 \
            -days 3650 \
            -subj "/CN=beekeeper"
    fi

    chmod 600 "$CAKEYFILE"

    # create configmap with ca certificate
    mkdir -p configmaps
    cat > configmaps/beehive-ca-certificate.yaml <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: beehive-ca-certificate
data:
  cacert.pem: |
$(awk '{print "    " $0}' ca/cacert.pem)
EOF
}

sign_credentials() {
    name="$1"
    keyfile="credentials/server/$name/key.pem"
    csrfile="credentials/server/$name/csr.pem"
    certfile="credentials/server/$name/cert.pem"

    mkdir -p "$(dirname $keyfile)"
    chmod 700 "credentials"

    # create signing request
    openssl req -new \
        -nodes -newkey rsa:4096 -keyout "$keyfile" -out "$csrfile" \
        -subj "/CN=$name"
    chmod 600 "$keyfile"

    # sign request using ca
    openssl x509 -req \
        -in "$csrfile" -out "$certfile" \
        -CAkey "$CAKEYFILE" -CA "$CACERTFILE" -CAcreateserial \
        -sha256 -days 365

    # create kuberenetes secret with key / cert
    mkdir -p secrets
    secret_name="${name}-tls-secret"
    cat > "secrets/${secret_name}.yaml" <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: ${secret_name}
type: Opaque
data:
  cert.pem: $(b64 "$certfile")
  key.pem: $(b64 "$keyfile")
EOF
}

sign_wes_rabbitmq_credentials() {
    name="$1"
    keyfile="credentials/client/$name/key.pem"
    csrfile="credentials/client/$name/csr.pem"
    certfile="credentials/client/$name/cert.pem"

    mkdir -p "$(dirname $keyfile)"
    chmod 700 "credentials"

    # create signing request
    openssl req -new \
        -nodes -newkey rsa:4096 -keyout "$keyfile" -out "$csrfile" \
        -subj "/CN=$name"
    chmod 600 "$keyfile"

    # sign request using ca
    openssl x509 -req \
        -in "$csrfile" -out "$certfile" \
        -CAkey "$CAKEYFILE" -CA "$CACERTFILE" -CAcreateserial \
        -sha256 -days 365

    # create kuberenetes secret with key / cert
    mkdir -p secrets
    secret_name="wes-beehive-rabbitmq-tls"
    cat > "secrets/${name}-${secret_name}.yaml" <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: ${secret_name}
type: Opaque
data:
  cert.pem: $(b64 "$certfile")
  key.pem: $(b64 "$keyfile")
EOF
}
