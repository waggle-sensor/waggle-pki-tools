#!/bin/bash -e

# detect correct base64 flags to use
if echo | base64 -b 0 &> /dev/null; then
  B64_FLAG="-b 0"
else
  B64_FLAG="-w 0"
fi

b64() {
  base64 "${B64_FLAG}" "$@"
}

CAKEYFILE="ca/ca"

init_ca() {
    mkdir -p "$(dirname $CAKEYFILE)"

    # create ca key / cert if key doesn't exist
    if ! test -e "$CAKEYFILE"; then
      ssh-keygen -N "" -f "$CAKEYFILE"
      ssh-keygen \
          -s "$CAKEYFILE" \
          -t rsa-sha2-256 \
          -I "beehive ssh ca" \
          -n "beehive" \
          -V "-5m:+36500d" \
          -h \
          "$CAKEYFILE"
    fi

    # create configmap with ca certificate
    mkdir -p configmaps
    cat > configmaps/beehive-ssh-ca.yaml <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: beehive-ssh-ca
data:
  ca.pub: $(cat ${CAKEYFILE}.pub)
  ca-cert.pub: $(cat ${CAKEYFILE}-cert.pub)
EOF
}

sign_host_credentials() {
    name="$1"
    keyfile="ca/$name"

    mkdir -p "$(dirname $keyfile)"
    ssh-keygen -N "" -f "$keyfile"
    ssh-keygen \
        -s "$CAKEYFILE" \
        -t rsa-sha2-256 \
        -I "$name ssh host key" \
        -n "$name" \
        -V "-5m:+365d" \
        -h \
        "$keyfile"

    # create kuberenetes secret with key / cert
    mkdir -p secrets
    secret_name="${name}-ssh-host-key"
    cat > "secrets/${secret_name}.yaml" <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: ${secret_name}
type: Opaque
data:
  ssh-host-key: $(b64 "${keyfile}")
  ssh-host-key.pub: $(b64 "${keyfile}.pub")
  ssh-host-key-cert.pub: $(b64 "${keyfile}-cert.pub")
EOF

    rm -f "$keyfile" "$keyfile.pub" "$keyfile-cert.pub"
}

sign_upload_credentials() {
    name="$1"
    keyfile="ca/$name"

    mkdir -p "$(dirname $keyfile)"
    ssh-keygen -N "" -f "$keyfile"
    ssh-keygen \
        -s "$CAKEYFILE" \
        -t rsa-sha2-256 \
        -I "$name ssh host key" \
        -n "$name" \
        -V "-5m:+365d" \
        "$keyfile"

    # create kuberenetes secret with key / cert
    mkdir -p secrets
    secret_name="${name}-wes-beehive-upload-ssh-key"
    cat > "secrets/${secret_name}.yaml" <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: wes-beehive-upload-ssh-key
type: Opaque
data:
  ssh-key: $(b64 "${keyfile}")
  ssh-key.pub: $(b64 "${keyfile}.pub")
  ssh-key-cert.pub: $(b64 "${keyfile}-cert.pub")
EOF

    rm -f "$keyfile" "$keyfile.pub" "$keyfile-cert.pub"
}
