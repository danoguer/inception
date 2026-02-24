# 🛠️ Developer Documentation

## 🏗️ Environment Setup

### 1. Prerequisites
To replicate this environment, the host machine must have:
* **Linux Kernel**: (Debian 12 Bookworm recommended).
* **Docker Engine**: v24.0+
* **Docker Compose**: v2.20+ (V2 plugin syntax: `docker compose`).
* **Make**: GNU Make.
* Host Mapping: echo "127.0.0.1 danoguer.42.fr" | sudo tee -a /etc/hosts

### 2. Build and launch the project

1. Secret Management (.env)

Developers must create a .env file in the srcs/ directory. This file is parsed by Docker Compose and injected into the containers.
```bash
# Domain & Infrastructure
DOMAIN_NAME=example.42.fr

# Database Configuration
SQL_USER=user
SQL_PASSWORD=password
SQL_ROOT_PASSWORD=rootpassword
SQL_DATABASE=wordpress

# WordPress Configuration
WP_ADMIN_USER=adminuser
WP_ADMIN_PASSWORD=password
WP_ADMIN_EMAIL=example@student.42madrid.com
WP_USER=user
WP_USER_PASSWORD=user1234

# FTP
FTP_USER=user
FTP_PASSWORD=password
```

2. Build & Deployment Logic

The project utilizes a Makefile to abstract complex Docker commands.

Useful Developer Commands
```bash
# Full Build	
make up
# Stop & Remove	
make down
# Removes containers and unused images.
make clean
# Full Data Reset
make fclean
# Turn everything off and on again
make re
# Clean Volumes	
docker volume rm $(docker volume ls -q)
# Access Shell	
docker exec -it <container_name> /bin/bash
# Check Network	
docker network inspect inception
```


💾 Data Persistence & Storage

Understanding where data lives is critical for debugging "stateless" containers.
1. Volume Mapping (Bind Mounts)

Per project requirements, we use Bind Mounts to map container directories to the host filesystem. This ensures that even if a container is deleted, the data remains on the host.
Container Path	Host Path (Local)	Data Type
/var/lib/mysql	/home/danoguer/data/mariadb	SQL Tables, Logs, Binary Logs
/var/www/html	/home/danoguer/data/wordpress	PHP scripts, Plugins, Uploads

2. Persistence Mechanism

    MariaDB: The setup.sh script checks for the existence of /var/lib/mysql/mysql. If missing, it runs the initialization bootstrap. If it exists, it skips setup to preserve existing data.

    WordPress: The setup.sh checks for wp-config.php. If present, it assumes an existing installation and only starts php-fpm.
