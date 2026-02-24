Inception

This project has been created as part of the 42 curriculum by danoguer. 

🌐 Description

🏗️ The Infrastructure
The core of the project is a LEMP-style stack (Linux, NGINX, MariaDB, PHP-FPM) orchestrated via Docker Compose. The architecture is divided into several dedicated microservices:
    NGINX: The only entry point to the infrastructure, strictly serving traffic over TLS v1.2/v1.3 to ensure security.
    WordPress + PHP-FPM: The dynamic content engine, decoupled from the web server for better scalability.
    MariaDB: The relational database management system, isolated within a private network.
    Bonus Services: A suite of additional tools including Redis (caching), FTP (file transfer), Adminer (DB management), cAdvisor (monitoring) and a Static Website.

⚙️ Key Constraints & Philosophy
This project is built following the "Everything-from-Scratch" philosophy required by the 42 pedagogy:
    Base OS: Every container is built using a minimal Debian (Bookworm) or Alpine image.
    No Pre-built Images: Using image: wordpress or image: mariadb from Docker Hub is forbidden. Every service is custom-built via a specific Dockerfile.
    Networking: All services communicate over a dedicated internal bridge network, with only NGINX exposing public ports.
    Data Persistence: Critical data is managed through Docker volumes mapped to specific host paths, ensuring that the infrastructure is stateless but the data is permanent.
    
🏗️ Design Choices
    Microservices Architecture: Instead of a "Monolithic" approach, each service (NGINX, MariaDB, WordPress, etc.) runs in its own isolated container. This follows the principle of Single Responsibility, making the system easier to debug and scale.
    Manual Orchestration: Every image is built via a custom Dockerfile. By avoiding pre-made Docker Hub images, we maintain total control over the binary versions (e.g., PHP 8.2, MariaDB 10.11) and security patches.
    Least Privilege: Services are configured to run as non-root users where possible (e.g., www-data for PHP), and only the NGINX container is permitted to communicate with the outside world.

⚖️ Technical Comparisons
A critical part of the Inception project is understanding the trade-offs between different virtualization and storage strategies.
1. Virtual Machines vs. Docker
    Virtual Machines (VMs): Virtualize the hardware. Each VM includes a full copy of an operating system, a virtual copy of the hardware, and the application. This makes them resource-heavy and slow to boot.
    Docker: Virtualizes the Operating System kernel. Containers share the host’s OS kernel, making them incredibly lightweight, fast to start, and efficient in terms of RAM and CPU usage.

2. Secrets vs. Environment Variables
    Environment Variables: Values stored in the shell environment (often loaded via a .env file). They are easy to use but can be visible via docker inspect or process listings, making them less secure for highly sensitive production data.
    Secrets: Encrypted data managed by Docker (specifically in Swarm mode or Kubernetes). Secrets are only unencrypted and mounted into the container’s memory at runtime, ensuring they never touch the disk in plain text. Note: For this project, we utilize .env files to simulate secure credential injection.

3. Docker Network vs. Host Network
    Host Network: The container shares the host's IP and port space directly. There is no isolation; if a container listens on port 80, it takes port 80 on the actual machine.
    Docker Network (Bridge): Creates a private virtual network. Containers can talk to each other using their service names (DNS), but are invisible to the outside world unless a port is explicitly mapped (e.g., 443:443). This provides a critical layer of network isolation.

4. Docker Volumes vs. Bind Mounts
    Docker Volumes: Managed entirely by Docker. They are stored in a part of the host filesystem that Docker controls (/var/lib/docker/volumes/). They are the preferred way to persist data because they are isolated from host system complexities.
    Bind Mounts: A specific path on the host machine is "bound" into the container (e.g., /home/danoguer/data ⮕ /var/www/html). We use Bind Mounts in this project to satisfy the requirement of storing data in a specific host directory for easy evaluation.


🚀 Instructions

📋 Prerequisites
Operating System: Linux (Debian Bookworm preferred).
Tools: docker, docker-compose, and make.
Permissions: You must have sudo privileges to modify host files and create data directories.

🔧 1. Host Configuration
The infrastructure communicates via a custom domain. You must map your local loopback address to the project domain in your /etc/hosts file:
echo "127.0.0.1 danoguer.42.fr" | sudo tee -a /etc/hosts

📂 2. Persistent Storage Setup
The MariaDB and WordPress services require physical directories on the host machine to persist data between reboots.
Bash
# Create the volume directories
sudo mkdir -p /home/$USER/data/mariadb
sudo mkdir -p /home/$USER/data/wordpress

🔐 3. Environment Variables
Before launching, ensure you have a .env file in the root directory containing the following secrets (refer to .env.example if available):
    MYSQL_ROOT_PASSWORD
    MYSQL_USER / MYSQL_PASSWORD
    DOMAIN_NAME (e.g., danoguer.42.fr)
    WP_ADMIN_USER / WP_ADMIN_PASSWORD

🛠️ 4. Installation & Launch
Use the provided Makefile to build and launch the entire infrastructure in detached mode:
Bash
# Build and start all containers
make
# Check the status of the services
docker ps

🌐 5. Accessing the Services
Once the build is complete and the containers are "healthy," you can access the infrastructure via your browser:
Service	URL	Protocol
WordPress	https://danoguer.42.fr	HTTPS (Port 443)
Adminer	https://danoguer.42.fr/adminer	HTTPS (Port 443)
Static Site	https://danoguer.42.fr/static	HTTPS (Port 443)
Cadvisor https://danoguer.42.fr/cadvisor HTTPS (Port 443)

    Note: Since we use self-signed SSL certificates, your browser will show a security warning. You can safely bypass this by clicking "Advanced" and "Proceed."

🧹 6. Maintenance & Cleanup
    Stop services: make stop
    Restart services: make re
    Full Cleanup: make fclean (Warning: This removes all containers, images, and volumes).


📚 Resources

🛠️ Docker & Orchestration
    Docker Official Documentation: The primary reference for Dockerfile instructions and docker-compose syntax.
    Docker Curriculum: A comprehensive guide to understanding containerization from the ground up.
    Play with Docker: An interactive classroom for testing bridge networking and volume behavior.

🌐 Networking & Security
    NGINX Core Functionality: Essential for configuring the reverse proxy and understanding the location block logic.
    Mozilla SSL Configuration Generator: Used to ensure TLS v1.2/v1.3 compliance and secure cipher suite selection.
    DigitalOcean Community Tutorials: Invaluable guides for setting up the LEMP stack and PHP-FPM socket/port configuration.

🗄️ Database & Backend
    MariaDB Knowledge Base: Documentation on user privileges, networking, and the mysql_install_db initialization process.
    PHP-FPM Documentation: Reference for process management and environment variable handling (clear_env).

🤖 AI Usage Disclosure
In the spirit of transparency and academic integrity, this project utilized Generative AI (Gemini) as a collaborative technical consultant. The integration of AI was focused on accelerating the learning curve of System Administration and DevOps best practices.
🛠️ Tasks Assisted by AI
    Infrastructure Debugging: Identifying and resolving version-specific conflicts, such as the MariaDB InnoDB redo log mismatch during the migration from Debian Bullseye to Bookworm (10.11).
    Script Optimization: Writing idempotent shell scripts (setup.sh) that use authenticated loops (mysqladmin ping) to ensure proper service orchestration and timing.
    Configuration Review: Auditing www.conf and 50-server.cnf to ensure they follow the "least privilege" principle and correct network binding (0.0.0.0).
    Documentation: Assistance in structuring and phrasing the README.md and DEV.md to meet professional industry standards.

🚫 Parts NOT Generated by AI
    System Architecture Design: The overall logic of the microservices and the mapping of volumes was manually designed based on the Inception Subject requirements.
    Security Implementation: The specific selection of TLS protocols and the isolation of the internal network were manually implemented to comply with 42's rigorous security standards.