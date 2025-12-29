#!/bin/bash

mkdir -p /etc/nginx/ssl

mkdir -p /var/log/nginx

# Remove symlinks (if official image created them)
[ -L /var/log/nginx/access.log ] && rm -f /var/log/nginx/access.log
[ -L /var/log/nginx/error.log ]  && rm -f /var/log/nginx/error.log

# Create real files
touch /var/log/nginx/access.log /var/log/nginx/error.log

# Ensure correct owner (www-data is the nginx user in Debian)
chown -R www-data:www-data /var/log/nginx
chmod 644 /var/log/nginx/*.log

if [ ! -f /etc/nginx/ssl/certificate.crt ] || [ ! -f /etc/nginx/ssl/certificate.key ]; then
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout /etc/nginx/ssl/certificate.key \
        -out /etc/nginx/ssl/certificate.crt \
        -subj "/C=MA/ST=BG/L=Benguerir/O=42/OU=42/CN=zel-harb.42.fr"\
        -addext "subjectAltName=DNS:zel-harb.42.fr,DNS:localhost,IP:127.0.0.1"
fi

nginx -t
exec nginx -g "daemon off;"