#!/bin/bash

mkdir -p /etc/nginx/ssl

if [ ! -f /etc/nginx/ssl/certificate.crt ] || [ ! -f /etc/nginx/ssl/certificate.key ]; then
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout /etc/nginx/ssl/certificate.key \
        -out /etc/nginx/ssl/certificate.crt \
        -subj "/C=MA/ST=BG/L=Benguerir/O=42/OU=42/CN=zel-harb.42.fr"\
        -addext "subjectAltName=DNS:zel-harb.42.fr,DNS:localhost,IP:127.0.0.1"
fi

nginx -t
exec nginx -g "daemon off;"
