Inception

This project has been created as part of the 42 curriculum by danoguer. 

Description

This project is a System Administration exercise focused on infrastructure virtualization using Docker. The goal is to build a secure, multi-container environment where each service runs in its own dedicated container. The architecture is designed for high security, featuring a single entry point via NGINX and TLS-encrypted communication.

Infrastructure Overview

The stack is built using Debian (penultimate stable version) to ensure performance and stability. Every image is custom-built using individual Dockerfiles; pulling ready-made images from DockerHub is strictly prohibited.

Core Services (Mandatory)

NGINX: The only entry point via port 443, using TLSv1.2/v1.3 exclusively.

WordPress: Configured with php-fpm and isolated from the web server.

MariaDB: Dedicated database container without external exposure.

Docker Network: A custom bridge network that handles internal container communication.

Docker Volumes: Two named volumes for persistent storage of website files and database records.

Bonus Services

Redis Cache: Optimized performance for the WordPress site.

FTP Server: Direct access to the WordPress volume for file management.

Adminer: A lightweight database management interface.

Static Website: A dedicated container serving non-PHP content.

cAdvisor: Real-time resource and performance monitoring for the entire stack.

Technical Design Choices
Concept	Comparison & Justification
VM vs. Docker	

VMs emulate hardware and include a full OS, whereas Docker shares the host kernel. I chose Docker for its significantly lower overhead and faster deployment cycles.

Secrets vs. Env Variables	

Environment variables are used for non-sensitive config , while Docker Secrets (or ignored .env files) are used for passwords. This prevents sensitive data from leaking into the Git history.

Docker Network vs. Host	

Host networking exposes containers directly to the host's IP. I used a custom Docker network to ensure containers only communicate with each other, minimizing the attack surface.

Volumes vs. Bind Mounts	

Bind mounts are tied to the host's file structure. I used Docker Named Volumes as they are more portable and allow Docker to manage the underlying storage logic securely.

Instructions

Prerequisites:
A machine running Debian.
Docker and Docker Compose installed.
Your login-based data directory: /home/danoguer/data/.

Installation & Execution

    Clone the repository:
    Bash

git clone https://github.com/your-repo/inception.git && cd inception

Configure Environment:
Create a srcs/.env file. Warning: Never commit this file to Git.

Build and Run: 

Bash

make

Local Access:
Add 127.0.0.1 danoguer.42.fr to your /etc/hosts file.

Resources

    Docker Documentation

    Debian Administrator's Handbook

    AI Usage Disclosure: AI was utilized to draft documentation structures, debug NGINX configuration loops, and clarify the distinction between PHP-FPM and standard NGINX hosting. All AI-generated logic was peer-reviewed to ensure full understanding.