# 1. The Base OS
FROM debian:bookworm

# 2. Install PHP-FPM, the MySQL connector for PHP, and wget (to download things)
RUN apt-get update -y && apt-get upgrade -y && \
    apt-get install -y php8.2-fpm php8.2-mysql php8.2-redis wget \
    mariadb-client

# 3. Download WP-CLI (The tool to install WordPress via terminal)
RUN wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

# 4. Copy our custom PHP configuration
COPY conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf

# 5. Copy our initialization script
COPY tools/setup.sh /usr/local/bin/setup.sh
RUN chmod +x /usr/local/bin/setup.sh

# 6. Create the folder where PHP-FPM needs to store its runtime socket
RUN mkdir -p /run/php

# 7. Set the default folder where all future commands will run
WORKDIR /var/www/html

# 8. Start the setup script
CMD ["/usr/local/bin/setup.sh"]