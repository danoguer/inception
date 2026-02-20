#!/bin/bash

# 1. Ensure runtime directories exist with correct permissions
mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld
chown -R mysql:mysql /var/lib/mysql

# 2. Check if the database already exists
if [ ! -d "/var/lib/mysql/$SQL_DATABASE" ]; then
    echo "Initializing MariaDB for the first time..."

    # Start MariaDB temporarily in the background without networking for setup
    mariadbd --user=mysql --bootstrap << EOF
USE mysql;
FLUSH PRIVILEGES;
CREATE DATABASE IF NOT EXISTS \`${SQL_DATABASE}\`;
CREATE USER IF NOT EXISTS \`${SQL_USER}\`@'%' IDENTIFIED BY '${SQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${SQL_DATABASE}\`.* TO \`${SQL_USER}\`@'%';
ALTER USER 'root'@'localhost' IDENTIFIED BY '${SQL_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
EOF
    echo "MariaDB configuration complete."
else
    echo "MariaDB already initialized."
fi

# 3. Start MariaDB in the foreground
echo "Starting MariaDB..."
exec mariadbd --user=mysql --console