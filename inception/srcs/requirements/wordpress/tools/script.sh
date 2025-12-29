#!/bin/bash

mkdir -p /run/php
chown www-data:www-data /run/php
php-fpm7.4 -F &
sleep 20
echo "Connected to MariaDB"

echo "Setting up WordPress..."

cd /var/www/html
# rm -f wp-config.php
echo "🔧 Creating wp-config.php..."
if [ ! -f /var/www/html/wp-config.php ]; then
    wp core download --allow-root
    wp config create \
        --dbname="$MYSQL_DATABASE" \
        --dbuser="$MYSQL_USER" \
        --dbpass="$MYSQL_PASSWORD" \
        --dbhost="$DB_HOST" \
        --allow-root
fi
if ! wp core is-installed --allow-root; then
    wp core install \
	    --url="https://zel-harb.42.fr" \
	    --title="$TITLE" \
	    --admin_user="$ADMIN_USER" \
	    --admin_password="$ADMIN_USER_PASSWORD" \
	    --admin_email="$ADMIN_USER_EMAIL" \
	    --skip-email \
	    --allow-root
fi
if ! wp user get $SECOND_USER --allow-root &>/dev/null; then
    echo "Creating second user..."
    wp user create $SECOND_USER $SECOND_USER_EMAIL \
        --user_pass=$SECOND_USER_PASSWORD \
        --role=subscriber \
        --allow-root
fi

echo "✅ WordPress installed successfully!"

echo "✅ WordPress is running with PHP-FPM on port 9000..."

wait