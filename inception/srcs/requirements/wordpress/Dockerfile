FROM debian:bullseye


RUN apt-get update


RUN apt-get install -y \
    php7.4-fpm \
    php7.4-mysql \
    php7.4-curl \
    php7.4-xml \
    php7.4-mbstring \
    wget \
    curl \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/www/html


RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

COPY tools/script.sh /usr/local/bin/script.sh
RUN chmod +x /usr/local/bin/script.sh


RUN chown -R www-data:www-data /var/www/html


RUN echo "listen = 9000" >> /etc/php/7.4/fpm/pool.d/www.conf


CMD ["/usr/local/bin/script.sh"]