Developer Documentation - Infrastructure Configuration
Environment Setup
Prerequisites

    Virtual Machine: Debian (penultimate stable version).

Tools: Docker Engine, Docker Compose, and make.

DNS Configuration: Map 127.0.0.1 to danoguer.42.fr in the host's /etc/hosts file.

Configuration

    Automated Setup: The Makefile is designed to automatically create the required directory structure at /home/danoguer/data/.

Environment: Manually create the srcs/.env file based on the template before the first build.

Building and Launching

The project lifecycle is fully automated via the root Makefile:

    make: Creates host data directories, builds custom Docker images, and launches the stack.

    make re: Forces a full rebuild of the infrastructure without using cache.

Data Persistence

Data is stored using Docker Named Volumes. To meet project requirements, these volumes are mapped to the host's physical storage:

    Database: /home/danoguer/data/mariadb.

Website Files: /home/danoguer/data/wordpress.

Security Requirements

    No "Hacky" Patches: No container uses tail -f, sleep infinity, or infinite loops as an entry point.

Strict TLS: NGINX is restricted to TLS v1.2 or v1.3 only.

User Privileges: The WordPress administrator username cannot contain "admin" or "administrator".

Network Isolation: All containers communicate via a dedicated internal bridge network.

.env File Syntax

Before building, you must create a file named .env in the srcs/ directory. The Makefile and docker-compose.yml rely on the following variable structure:

# Domain & Infrastructure
DOMAIN_NAME=danoguer.42.fr

# Database Configuration
SQL_USER=user
SQL_PASSWORD=your_secure_password
SQL_ROOT_PASSWORD=your_root_password
SQL_DATABASE=wordpress

# WordPress Configuration
WP_ADMIN_USER=wp_manager
WP_ADMIN_PASSWORD=admin_password
WP_USER=wp_visitor
WP_USER_PASSWORD=visitor_password

# Bonus: FTP & Redis
FTP_USER=danogueruser
FTP_PASSWORD=ftp_password

Note: As per security requirements, the WordPress administrator username must not contain "admin" or "administrator".