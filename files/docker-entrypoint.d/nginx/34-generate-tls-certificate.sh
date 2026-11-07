#!/bin/sh

set -e
ME=$(basename $0)

# Generate a self-signed certificate on first start if none is mounted.
# Keeping the key out of the image means every deployment gets its own key.
if [ "${BAIKAL_HTTP_ONLY:-}" = "true" ]; then
  exit 0
fi

CERT=/etc/nginx/ssl/nginx.crt
KEY=/etc/nginx/ssl/nginx.key

if [ -s "$CERT" ] && [ -s "$KEY" ]; then
  echo "$ME: info: using existing certificate in /etc/nginx/ssl"
  exit 0
fi

# Never overwrite a partially provided certificate: a single mounted file
# means the mount is incomplete, so stop instead of replacing the other one.
if [ -e "$CERT" ] || [ -e "$KEY" ]; then
  echo "$ME: error: found only one of $CERT and $KEY, provide both or neither" >&2
  exit 1
fi

echo "$ME: info: generating self-signed certificate in /etc/nginx/ssl"
mkdir -p /etc/nginx/ssl
umask 077
openssl req -x509 -nodes -days 3650 -newkey rsa:2048 -subj "/CN=baikal" -addext "subjectAltName=DNS:localhost" -addext "basicConstraints=critical,CA:FALSE" -keyout "$KEY" -out "$CERT"
