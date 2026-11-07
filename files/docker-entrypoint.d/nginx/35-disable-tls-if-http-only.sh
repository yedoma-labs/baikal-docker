#!/bin/sh

set -e
ME=$(basename $0)

# Serve Baikal over plain HTTP only when BAIKAL_HTTP_ONLY=true, e.g. when TLS is
# terminated by a reverse proxy in front of the container. Removes the HTTPS
# listener and certificate directives from the Nginx configuration.
if [ "${BAIKAL_HTTP_ONLY:-}" != "true" ]; then
  exit 0
fi

echo "$ME: info: BAIKAL_HTTP_ONLY is set, disabling HTTPS listener in Nginx configuration."

sed -i -e '/listen 443 ssl;/d' -e '/ssl_certificate/d' /etc/nginx/conf.d/default.conf
