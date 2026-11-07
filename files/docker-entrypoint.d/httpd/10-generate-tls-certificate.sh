#!/bin/sh

set -e
ME=$(basename $0)

# Generate a self-signed certificate on first start if none is mounted.
# Keeping the key out of the image means every deployment gets its own key.
CERT=/etc/ssl/private/baikal.public.pem
KEY=/etc/ssl/private/baikal.private.pem

if [ -s "$CERT" ] && [ -s "$KEY" ]; then
  echo "$ME: info: using existing certificate in /etc/ssl/private"
  exit 0
fi

echo "$ME: info: generating self-signed certificate in /etc/ssl/private"
umask 077
openssl req -x509 -nodes -days 3650 -newkey rsa:2048 -subj "/CN=baikal" -addext "subjectAltName=DNS:localhost" -addext "basicConstraints=critical,CA:FALSE" -keyout "$KEY" -out "$CERT"
