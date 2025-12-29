FROM debian:bullseye

RUN apt-get update && \
    apt-get install -y nginx openssl

# Create SSL directory
RUN mkdir -p /etc/nginx/ssl
# Add this to your nginx Dockerfile
RUN chmod 755 /var/log/nginx && \
    touch /var/log/nginx/access.log /var/log/nginx/error.log && \
    chmod 644 /var/log/nginx/access.log /var/log/nginx/error.log

# Copy nginx configuration to correct location
COPY conf/file.conf /etc/nginx/conf.d/default.conf

# Copy script
COPY tools/script.sh /usr/local/bin/script.sh
RUN chmod +x /usr/local/bin/script.sh

CMD ["/usr/local/bin/script.sh"]