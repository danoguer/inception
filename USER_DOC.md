User Documentation - Inception Infrastructure
Services Overview

This infrastructure provides a secure, containerized web stack consisting of:

WordPress: The primary CMS for content management.

NGINX: The secure entry point for all traffic (TLS v1.2/v1.3).

MariaDB: The relational database for persistent data storage.

Redis (Bonus): Object cache to speed up WordPress performance.

FTP (Bonus): Secure file transfer access to the WordPress content volume.

Adminer (Bonus): A web-based interface for database management.

Static Website (Bonus): A resume/showcase site built in HTML/CSS.

Cadvisor (Bonus): To check every information about the containers.

Operations

Starting and Stopping 

    Launch: Run make in the root directory. This builds and starts all services in detached mode.

    Stop: Run make down to stop and remove containers while keeping volumes intact.

    Full Reset: Run make fclean to remove everything, including persistent volumes and networks.

Accessing the Website 

    Main Site: https://danoguer.42.fr

    Admin Panel: https://danoguer.42.fr/wp-admin

    Adminer: https://danoguer.42.fr/adminer

    Static Site: https://danoguer.42.fr/portfolio

    Cadvisor: https://danoguer.42.fr/cadvisor

Credential Management 

All passwords and sensitive keys are managed via a .env file located in the srcs/ directory. For the defense, these credentials are kept local and are never pushed to Git.

Health Check 

To verify services are running:

docker ps: Lists all active containers. All should show a status of "Up".

docker network ls: Ensures the inception_network is created.

docker volume ls: Ensures mariadb_data and wordpress_data are present.