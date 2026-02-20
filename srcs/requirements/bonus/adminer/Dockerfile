FROM debian:bookworm

# Install PHP and the MySQL extension so it can talk to MariaDB
RUN apt-get update -y && apt-get upgrade -y && \
    apt-get install -y php8.2 php8.2-mysql wget

# Download the Adminer script and name it adminer.php
RUN wget "https://www.adminer.org/latest.php" -O /var/www/html/adminer.php

# Use PHP's built-in web server to serve the file on port 8080
WORKDIR /var/www/html
CMD ["php", "-S", "0.0.0.0:8080", "adminer.php"]