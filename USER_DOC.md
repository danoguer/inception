# 📖 User & Administrator Documentation

This document provides essential information for operating, managing, and accessing the Inception infrastructure.

---

## 🛠️ Provided Services
**WordPress** | Main Content Management System (CMS). |
https://danoguer.42.fr

**WordPress admin**
https://danoguer.42.fr/wp-admin

**Static Site** | Lightweight static landing page. |
https://danoguer.42.fr/portfolio

**Adminer** | Web-based Database Management tool. |
https://danoguer.42.fr/adminer

**cAdvisor** | Real-time resource usage and container monitoring. |
https://danoguer.42.fr/cadvisor	

**Redis** | High-speed object caching for WordPress performance. |
https://danoguer.42.fr/wp-admin -> Plugins Menu

**FTP** | File Transfer Protocol for direct file management. |
`ftp https://danoguer.42.fr`
---

## 🚦 System Operations

⏺️ Starting the Project
To initialize and launch the infrastructure, navigate to the project root and run:

`make`

⏹️ Stopping the Project

To stop the services while keeping the data intact:

`make stop`

To shut down and remove the containers.
`make down`


🔑 Credential Management

You have to create a .env file following this syntax:

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


🩺 Health & Monitoring
1. Visual Health Check

Access cAdvisor at https://danoguer.42.fr/cadvisor to monitor CPU, memory, and network usage for every individual container.
2. Terminal Status Check

To see a quick overview of which services are up or down:

`docker ps`

3. Log Inspection

If a service is not responding correctly, inspect the live logs:

```bash
# General logs
docker compose logs -f

# Specific service logs (e.g., MariaDB)
docker logs mariadb
```

🏛️ Support

For technical issues regarding the architecture, refer to the DEV.md file. For deployment issues, ensure Docker is running and the .env file is properly formatted.