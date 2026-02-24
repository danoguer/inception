# 🐳 Inception

This project was created by danoguer as part of the 42 curriculum.


## 🌐 Description
It focuses on system administration, containerization, and the orchestration of a complex microservices infrastructure.
The core of the project is a LEMP-style stack orchestrated via Docker Compose. The architecture is divided into several dedicated microservices:

NGINX: The only entry point to the infrastructure, strictly serving traffic over TLS v1.2/v1.3 to ensure security.

WordPress + PHP-FPM: The dynamic content engine, decoupled from the web server for better scalability.

MariaDB: The relational database management system, isolated within a private network.

Bonus Services: A suite of additional tools including Redis (caching), FTP (file transfer), Adminer (DB management), cAdvisor (monitoring), and a Static Website.


### ⚙️ Key Constraints & Philosophy

This project is built following the "Everything-from-Scratch" philosophy required by the 42 pedagogy:

Base OS: Every container is built using a minimal Debian (Bookworm) or Alpine image.

No Pre-built Images: Using image: wordpress or image: mariadb from Docker Hub is forbidden. Every service is custom-built via a specific Dockerfile.

Networking: All services communicate over a dedicated internal bridge network, with only NGINX exposing public ports.

Data Persistence: Critical data is managed through Docker volumes mapped to specific host paths, ensuring that the infrastructure is stateless but the data is permanent.


### 🏗️ Design Choices

Microservices Architecture: Instead of a "Monolithic" approach, each service runs in its own isolated container. This follows the principle of Single Responsibility, making the system easier to debug and scale.

Manual Orchestration: By avoiding pre-made Docker Hub images, we maintain total control over binary versions (e.g., PHP 8.2, MariaDB 10.11) and security patches.

Least Privilege: Services run as non-root users where possible (e.g., www-data for PHP), and only the NGINX container is permitted to communicate with the outside world.


### ⚖️ Technical Comparisons


🖥️ Docker vs Virtual Machine

Architecture: VMs use a Hypervisor to emulate physical hardware; Docker uses the Docker Engine to interface with the Host OS.

Kernel: Each VM boots its own Guest OS Kernel; all Docker containers share the single Host OS Kernel.

Isolation Mechanism: VMs provide Hardware-level isolation (secure but heavy); Docker uses Namespaces and Cgroups for process-level isolation (fast but shared).

Resource Payload: VMs include a full OS (drivers, binaries, kernel), costing GBs; Docker includes only the app and its libraries, costing MBs.

Startup: VMs undergo a full BIOS/OS boot sequence (minutes); Docker starts as a forked process (milliseconds).

Efficiency: VMs have high overhead due to redundant OS tasks; Docker runs at near-native speed with zero hardware emulation tax.


🔐 Secrets vs. Environment Variables

Environment Variables: Easily visible via docker inspect. Suitable for non-sensitive config.

Secrets: Managed in memory at runtime (Swarm/K8s). For this project, we utilize .env files to simulate secure credential injection.


🌐 Docker Network vs. Host Network

Host Network: Shares the host's IP/ports. Zero isolation.

Docker Bridge Network: Private virtual network. Containers use service names (DNS) for internal talk, remaining invisible to the outside world.


💾 Docker Volumes vs. Bind Mounts

Docker Volumes: Managed by Docker in /var/lib/docker/volumes/. Best for production.

Bind Mounts: Maps a specific host path to the container. Used here to satisfy the requirement of storing data in a specific host directory for evaluation.


## 🚀 Instructions


### 📋 Prerequisites

OS: Linux (Debian Bookworm preferred).

Tools: docker, docker-compose, and make.

Permissions: sudo privileges are required.


### 🔧 1. Host Configuration

Map your local loopback address to the project domain in your /etc/hosts file:


`echo "127.0.0.1 danoguer.42.fr" | sudo tee -a /etc/hosts`


### 📂 2. Persistent Storage Setup

Create the volume directories

`sudo mkdir -p /home/$USER/data/mariadb`

`sudo mkdir -p /home/$USER/data/wordpress`


### 🔐 3. Environment Variables

Ensure you create a .env file in the root directory with the following (refer to .env.example):

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


### 🛠️ 4. Installation & Launch

Build and start all containers

`make`

Check the status of the services

`docker ps`


### 🌐 5. Accessing the Services
Service	URL	Protocol

WordPress	https://danoguer.42.fr	HTTPS (443)

Adminer	https://danoguer.42.fr/adminer	HTTPS (443)

Static Site	https://danoguer.42.fr/static	HTTPS (443)

Cadvisor	https://danoguer.42.fr/cadvisor	HTTPS (443)

[!CAUTION]
Since we use self-signed SSL certificates, your browser will show a security warning. Click "Advanced" → "Proceed".


### 🧹 6. Maintenance

Stop services: 

`make stop`

Restart services: 

`make re`

Full Cleanup:

`make fclean` (Warning: Removes containers, images, and volumes).


## 📚 Resources

Docker Official Documentation

NGINX Core Functionality

MariaDB Knowledge Base

Mozilla SSL Configuration Generator


### 🤖 AI Usage Disclosure

In the spirit of transparency, this project utilized Gemini as a technical consultant to accelerate the learning curve of System Administration and DevOps.

Assisted Tasks:

Infrastructure Debugging: Resolved MariaDB InnoDB redo log mismatches during the Debian Bullseye to Bookworm migration.

Script Optimization: Wrote idempotent setup.sh scripts using mysqladmin ping for service orchestration.

Configuration Review: Audited www.conf and 50-server.cnf for "least privilege" compliance.

Manually Implemented (No AI):

System Architecture Design: Core logic and volume mapping based on Inception requirements.

Security Implementation: TLS protocol selection and network isolation strategy.