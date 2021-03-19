#!/bin/bash

CAKEYFILE="ca/cakey.pem"
CACERTFILE="ca/cacert.pem"

init_ca() {
    mkdir -p "$(dirname $CAKEYFILE)"

    # make sure we don't accidentally overwrite an existing ca key!
    if test -e "$CAKEYFILE"; then
        echo "$CAKEYFILE already exists - skipping"
        return
    fi

    # create ca
    openssl req -x509 \
        -nodes -newkey rsa:4096 -keyout "$CAKEYFILE" -out "$CACERTFILE" \
        -sha256 -days 36500 -subj "/CN=beekeeper"
}

sign_credentials() {
    name="$1"
    keyfile="ca/$name.key.pem"
    csrfile="ca/$name.csr.pem"
    certfile="ca/$name.cert.pem"

    mkdir -p "$(dirname $keyfile)"

    # create signing request
    openssl req -new \
        -nodes -newkey rsa:4096 -keyout "$keyfile" -out "$csrfile" \
        -subj "/CN=$name"

    # sign request using ca
    openssl x509 -req \
        -in "$csrfile" -out "$certfile" \
        -CAkey "$CAKEYFILE" -CA "$CACERTFILE" -CAcreateserial \
        -sha256 -days 365

    # also create kuberenetes secret resource for immediate use
    # TODO(sean) think about whether this is primary thing we want to ship. it's a flexible 
    # format which already includes the essentials, room to grow and is also immediately
    # usable by kubernetes
    mkdir -p secrets

    secret_name="${name}-tls-secret"
    cat > "secrets/${secret_name}.yaml" <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: ${secret_name}
type: Opaque
data:
  cacert.pem: $(base64 "$CACERTFILE")
  cert.pem: $(base64 "$certfile")
  key.pem: $(base64 "$keyfile")
EOF

    rm -f "$keyfile" "$csrfile" "$certfile"
}
