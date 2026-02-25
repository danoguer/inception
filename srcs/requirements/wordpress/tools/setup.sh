#!/bin/bash

# Ensure we are working in the correct web directory
cd /var/www/html

# Put Wordpress to sleep if ariadb is not ready
echo "Waiting for MariaDB to wake up..."
until mysqladmin ping -h"mariadb" -u root -p"${SQL_ROOT_PASSWORD}"; do
    echo "MariaDB is unavailable - sleeping"
    sleep 2
done

# 2. Idempotency Check
if [ ! -f "wp-config.php" ]; then
    echo "WordPress not found. Downloading..."
    wp core download --allow-root

# Creating the wp-config.php file on our volume
    echo "Configuring database connection..."
    wp config create --dbname=$SQL_DATABASE \
                     --dbuser=$SQL_USER \
                     --dbpass=$SQL_PASSWORD \
                     --dbhost=mariadb:3306 \
                     --allow-root

# Connects to the mariadb data base to create the SQL tables
    echo "Installing WordPress..."
    wp core install --url=$DOMAIN_NAME \
                    --title="Inception" \
                    --admin_user=$WP_ADMIN_USER \
                    --admin_password=$WP_ADMIN_PASSWORD \
                    --admin_email=$WP_ADMIN_EMAIL \
                    --allow-root

    echo "Creating standard user..."
    wp user create $WP_USER $WP_USER_EMAIL --role=author --user_pass=$WP_USER_PASSWORD --allow-root

    # === BONUS CONFIGURATION ===
    echo "Configuring Redis..."
    wp config set WP_REDIS_HOST redis --allow-root
    wp config set WP_REDIS_PORT 6379 --allow-root
    wp config set FS_METHOD direct --allow-root
    
    echo "Installing Redis plugin..."
    wp plugin install redis-cache --activate --allow-root
    wp redis enable --allow-root
else
    echo "WordPress already installed."
    wp redis enable --allow-root
fi

echo "Applying ownership to www-data..."

# Change the owner and the group of the files for making changes after
chown -R www-data:www-data /var/www/html

# Giving permissions to the files
chmod -R 775 /var/www/html

# 3. Start PHP-FPM 8.2 in the foreground
echo "Starting PHP-FPM 8.2..."
exec /usr/sbin/php-fpm8.2 -F