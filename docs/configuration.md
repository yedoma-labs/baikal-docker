# Configuration Guide

This guide lists the options you can set when running the `yedomalabs/baikal` images:
environment variables, volumes, ports and reverse proxy setup. For certificates, see the
[SSL Certificate Guide](ssl-certificates-guide.md).

## Environment variables

| Variable                   | Apache | Nginx | Description                                                                                                                                               |
| -------------------------- | :----: | :---: | --------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `BAIKAL_HTTP_ONLY`         |   -    |  yes  | Set to `true` to serve only HTTP on port 80. The HTTPS listener and certificate settings are removed. Use this when TLS is terminated by a reverse proxy. |
| `BAIKAL_SERVERNAME`        |  yes   |   -   | Sets Apache's `ServerName`, e.g. `dav.example.com`. Avoids Apache warnings in the log.                                                                    |
| `BAIKAL_SERVERALIAS`       |  yes   |   -   | Sets Apache's `ServerAlias`, e.g. `dav.example.org dav.example.com`.                                                                                      |
| `BAIKAL_ENABLE_CHOWN`      |  yes   |  yes  | Set to `true` to run `chown -R` on `/var/www/baikal` at startup. Useful after switching between Apache and Nginx images.                                  |
| `RESPECT_BAIKAL_BASE_URI`  |   -    |  yes  | Set to any value to serve Baikal from the `base_uri` in its configuration, e.g. `/baikal`.                                                                |
| `MSMTPRC`                  |  yes   |  yes  | Contents of `/etc/msmtprc`, used to send mail. See the [Email Guide](email-guide.md).                                                                     |
| `APPLY_HOME_ASSISTANT_FIX` |  yes   |  no   | Set to `true` to apply the Home Assistant fix. Not supported by the PHP 8.4 Nginx build. See the [Home Assistant Fix](home-assistant-fix.md).             |

Variables that are not listed here have no effect on the image.

## Volumes

| Path in container          | Contents                                                                                                       |
| -------------------------- | -------------------------------------------------------------------------------------------------------------- |
| `/var/www/baikal/config`   | Baikal configuration. Back this up.                                                                            |
| `/var/www/baikal/Specific` | Baikal data, including the SQLite database. Back this up.                                                      |
| `/etc/nginx/ssl`           | Nginx only: `nginx.crt` and `nginx.key`. Optional, see the [SSL Certificate Guide](ssl-certificates-guide.md). |
| `/etc/ssl/private`         | Apache only: `baikal.public.pem` and `baikal.private.pem`. Optional.                                           |

## Ports

- `80`: HTTP. Always exposed.
- `443`: HTTPS with a certificate generated on first start, or with your own certificate.
  Not used when `BAIKAL_HTTP_ONLY=true`.

## TLS and certificates

- If no certificate is mounted, the container generates a self-signed certificate on its first start.
  The private key stays inside the container and is not part of the image.
- If you mount a certificate, mount both files. If only one of them is present, the container stops
  with an error instead of replacing the file you provided.
- With `BAIKAL_HTTP_ONLY=true` (Nginx), no certificate is generated and no HTTPS listener is started.

## Behind a reverse proxy

When a proxy such as Traefik, nginx or Caddy terminates TLS in front of Baikal:

1. Set `BAIKAL_HTTP_ONLY=true` on the Nginx variant, so the container serves only HTTP.
2. Make sure the proxy sends the `X-Forwarded-Proto` header. Baikal uses it to build the
   CalDAV and CardDAV redirects (`/.well-known/caldav` and `/.well-known/carddav`). Without it,
   clients are redirected to `http://`. Traefik sends this header by default.
3. Forward the `Host` header unchanged, so the redirects point to your public hostname.

Example for a Dokploy or Traefik setup with Cloudflare in front:

```yaml
services:
  baikal:
    image: yedomalabs/baikal:nginx
    environment:
      BAIKAL_HTTP_ONLY: "true"
    volumes:
      - baikal-config:/var/www/baikal/config
      - baikal-data:/var/www/baikal/Specific
volumes:
  baikal-config:
  baikal-data:
```

The proxy then terminates TLS for your public hostname and forwards requests to port 80 of the container.

## Architectures

| Variant | amd64 | arm/v7 | arm64 | i386 |
| ------- | :---: | :----: | :---: | :--: |
| Apache  |  yes  |  yes   |  yes  | yes  |
| Nginx   |  yes  |  yes   |  yes  |  no  |

The Nginx variants install PHP from a third-party repository that does not publish i386 packages.
For details, see the [Nginx / PHP 8.4 upgrade guide](nginx-php84-upgrade.md).
