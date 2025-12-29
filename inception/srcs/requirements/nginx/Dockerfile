FROM debian:bullseye

RUN apt-get update && \
    apt-get install -y nginx openssl

# Create SSL directory
RUN mkdir -p /etc/nginx/ssl

# Copy nginx configuration to correct location
COPY conf/file.conf /etc/nginx/conf.d/default.conf

# Copy script
COPY tools/script.sh /usr/local/bin/script.sh
RUN chmod +x /usr/local/bin/script.sh

CMD ["/usr/local/bin/script.sh"]