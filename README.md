# 🐳 Inception: Production-Ready Microservices Orchestration & Systems Infrastructure

[![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)](https://www.docker.com/)
[![NGINX](https://img.shields.io/badge/Nginx-009639?style=for-the-badge&logo=nginx&logoColor=white)](https://nginx.org/)
[![MariaDB](https://img.shields.io/badge/MariaDB-003545?style=for-the-badge&logo=mariadb&logoColor=white)](https://mariadb.org/)
[![Debian](https://img.shields.io/badge/Debian-A81D33?style=for-the-badge&logo=debian&logoColor=white)](https://www.debian.org/)
[![Redis](https://img.shields.io/badge/Redis-DC382D?style=for-the-badge&logo=redis&logoColor=white)](https://redis.io/)

A complete, enterprise-grade Infrastructure-as-Code project focused on system administration, network virtualization, and multi-container orchestration. Developed as part of the advanced 42 curriculum.

> 📝 **Architectural Deep-Dive:** This project is backed by an extensive multi-part technical analysis covering the entire engineering process. Read the full series here: [My 42 Journey - Inception Blog](https://42-journey.hashnode.dev/series/inception).

---

## 🌐 System Architecture & Request Lifecycle

The infrastructure builds a secure, highly-available LEMP-style stack encapsulated within strictly isolated virtual networks. Only NGINX interfaces with the outside world, acting as the reverse proxy and security perimeter.

### Infrastructure Topology

```text
       [ Public Internet ] 
               │
               ▼ (Port 443 - HTTPS / TLS 1.3)
      ┌────────────────────────────────────────────────────────┐
      │                  NGINX Container                       │
      │   (SSL Termination & Layer 7 Routing Perimeter)       │
      └───────┬────────────────┬────────────────┬──────────────┘
              │                │                │
              │ (FastCGI)      │ (Proxy)        │ (Proxy)
              ▼                ▼                ▼
     ┌────────────────┐┌───────────────┐┌───────────────┐
     │ WordPress +    ││    Adminer    ││   cAdvisor    │
     │ PHP-FPM 8.2    ││ (DB Manager)  ││ (Monitoring)  │
     └───────┬────────┘└───────┬───────┘└───────┬───────┘
             │                 │                │
   ┌─────────┴─────────┐       │                │
   │   Internal Link   │       │                │
   ▼                   ▼       ▼                ▼
┌────────────────┐  ┌───────────────────────────────────┐
│  Redis Cache   │  │         MariaDB Database          │
│ (Object Cache) │  │  (Isolated Relational Storage)    │
└────────────────┘  └───────────────────────────────────┘
        ▲                                 ▲
        └─────────── Dedicated ───────────┘
                 Docker Volumes
```

### Request Flow Timeline
1. **Ingress:** The client initiates a secure connection to `https://danoguer.42.fr`.
2. **TLS Termination:** NGINX intercepts the traffic on port 443, enforces TLS 1.3 handshake protocols, decrypts the request, and performs health checks.
3. **Layer 7 Routing:** * Dynamic PHP traffic is multiplexed and forwarded to the **WordPress** engine via the FastCGI protocol on port 9000.
   * Administrative routes (`/adminer`, `/cadvisor`) are reverse-proxied to their respective sandboxed utilities.
4. **Data & Cache Layer:** WordPress checks runtime queries against the **Redis** in-memory object cache. On a cache miss, it executes structural queries to the isolated **MariaDB** back-end (port 3306).

---

## 🗄️ Microservices Breakdown

| Service | Technology | Role & Engineering Implementation |
| :--- | :--- | :--- |
| **Edge Proxy** | NGINX | The single structural entry point. Implements modern cryptographic baselines (TLS v1.2/v1.3), path-based reverse proxying, and static assets routing. |
| **Application** | WordPress + PHP-FPM | Decoupled dynamic processor running dedicated PHP-FPM daemons. Hardened against brute-force attacks via configurations injected at build time. |
| **Database** | MariaDB | Relational storage engine. Fully stripped of networking exposure to the host; reachable exclusively via internal intra-container networking. |
| **Caching** | Redis | NoSQL in-memory database acting as an application-level Object Cache, reducing DB query load and cutting latency down to single-digit milliseconds. |
| **File Transfer**| FTP Server | Secure vsftpd setup mapped directly to the WordPress runtime volume, allowing authenticated real-time configuration and media manipulation. |
| **DB Manager** | Adminer | Single-file, lightweight database management dashboard. Reverse-proxied behind NGINX to restrict arbitrary infrastructure visibility. |
| **Observability**| cAdvisor | Google-engineered telemetry agent. Scrapes hardware real-time saturation metrics (CPU, Memory, Network I/O) from the cgroups architecture. |
| **Landing Page** | Static Website | Independent, high-performance static HTML/CSS portfolio served straight from NGINX memory structures to showcase multi-root routing. |

---

## ⚙️ Architectural Decisions & Constraints

This system is built under the strict **"Zero Pre-built Images"** pedagogy of 42.

* **Bare-Metal OS Layer:** Every single microservice container is engineered starting from a clean, vanilla Unix distribution (`Debian Bookworm` or `Alpine Linux`). No standard DockerHub stacks (`image: wordpress`) allowed.
* **Hermetic Networks:** Multi-tier infrastructure architecture implemented through customized network bridges. Services are decoupled into functional layers (e.g., Database layer cannot talk to the Internet; only NGINX has exposed ports).
* **State Management:** Containers remain completely ephemeral and stateless. High-value transactional and application state is preserved through targeted Docker Volumes anchored to specific cryptographic host paths.
* **Principle of Least Privilege:** System execution layers are stripped of root authority. Daemon worker threads run strictly as non-privileged service accounts (e.g., `www-data` for PHP processing).

---

<details>
<summary><b>🔬 Deep Dive: OS Containerization vs. Hardware Virtualization (Click to expand)</b></summary>

| Architectural Metric | Docker Containers | Virtual Machines (VM) |
| :--- | :--- | :--- |
| **Abstraction Level** | App-space virtualization sharing the Host OS kernel. | Hardware emulation through a Hypervisor. |
| **Guest OS Overhead** | None. Uses host binaries and system calls. | Heavy. Requires an independent, full Guest OS boot. |
| **Isolation Barrier** | Process-level isolation via Linux `namespaces` and `cgroups`. | Hypervisor-enforced hardware security boundaries. |
| **Storage Payload** | Ultra-lightweight (measured in Megabytes). | Heavy footprint (measured in Gigabytes). |
| **Provisioning Speed** | Instantaneous process fork (Milliseconds). | Standard OS cold-boot lifecycle (Minutes). |
| **Hardware Tax** | Near-native bare-metal execution speed. | Execution penalty due to continuous hardware emulation. |

### 💾 Storage Design: Docker Volumes vs. Bind Mounts

| Dimension | Docker Managed Volumes | Native Host Bind Mounts |
| :--- | :--- | :--- |
| **Host Dependence** | High abstraction; managed inside `/var/lib/docker/`. | Tightly coupled to the host file system hierarchy. |
| **Portability** | OS-independent. Safe for Cloud orchestration (K8s/Swarm). | Breaks across multi-architecture nodes if paths mismatch. |
| **Performance** | Optimized performance directly inside the virtualization layer. | Standard file system performance; bound by host disk lockups. |

</details>

---

## 🚀 Deployment & Operations Guide

### 📋 Prerequisites
* **Operating System:** Linux distributions (Debian/Ubuntu native architectures recommended).
* **Toolchain:** Docker Engine (v20.10+), Docker Compose (v2.0+), GNU Make.
* **Privileges:** `sudo` administrative rights for network and directory mapping.

### 🔧 Step-by-Step Provisioning

#### 1. DNS Local Mapping
Inject the project routing domain into your local loopback configuration:
```bash
echo "127.0.0.1 danoguer.42.fr" | sudo tee -a /etc/hosts
```

#### 2. Storage Initialization
Prepare the physical local anchorage paths for database and media persistence:
```bash
sudo mkdir -p /home/$USER/data/mariadb
sudo mkdir -p /home/$USER/data/wordpress
```

#### 3. Environment Secrets Secret Management
Generate a secure `.env` file at the root configuration level. Use `.env.example` as your reference template:
```env
DOMAIN_NAME=danoguer.42.fr
SQL_USER=db_operator
SQL_PASSWORD=supersecureuserpass
SQL_ROOT_PASSWORD=supersecurerootpass
SQL_DATABASE=wordpress_prod
WP_ADMIN_USER=cloud_admin
WP_ADMIN_PASSWORD=adminsecurepass
WP_ADMIN_EMAIL=danoguer@student.42madrid.com
FTP_USER=ftp_operator
FTP_PASSWORD=ftpsecurepass
```

#### 4. Orchestration Execution
Compile, assemble, and launch the microservice clusters concurrently using the automated orchestration pipeline:
```bash
# Build and execute cluster in detached mode
make

# Monitor live operational readiness
docker ps
```

---

## 🌐 Ingress Exposure Mapping

Once runtime convergence is achieved, services route via the following rules:

| Application Target | Resolution Path | Encryption |
| :--- | :--- | :--- |
| **WordPress CMS** | `https://danoguer.42.fr` | TLS 1.3 (Port 443) |
| **Static Gateway** | `https://danoguer.42.fr/static` | TLS 1.3 (Port 443) |
| **Telemetry (cAdvisor)**| `https://danoguer.42.fr/cadvisor` | TLS 1.3 (Port 443) |
| **DB Administration** | `https://danoguer.42.fr/adminer` | TLS 1.3 (Port 443) |
| **Secure FTP Link** | `ftp://danoguer.42.fr` | Standard FTP Layer |

> ⚠️ **SSL Note:** Because this infrastructure deploys custom, self-signed SSL security certificates for internal verification, modern browsers will flag an authority alert on your initial connection. Bypass this via **Advanced -> Proceed to site**.

---

## 🧹 Infrastructure Lifecycle Commands

```bash
make stop     # Gracefully suspend cluster execution without losing state.
make re       # Trigger full microservice rebuild and configuration hot-reload.
make fclean   # Nuclear purge: Destroys containers, network loops, and wipes host persistent directories.
```

---

## 🤖 Engineering Leverage & AI Disclosure

In line with professional modern engineering principles, this infrastructure was optimized using **Gemini** acting as an automated Senior Systems Consultant. 

* **Accelerated Troubleshooting:** Debugged complex InnoDB redo log memory mismatches triggered during the base image architecture upgrade (`Debian Bullseye` to `Bookworm`).
* **Systems Idempotency:** Refined automated `setup.sh` routines, integrating structural health-checks (`mysqladmin ping`) to enforce dependency-ordered startup flows.
* **Security Auditing:** Audited low-level process configurations (`www.conf` and `50-server.cnf`) ensuring strict least-privilege compliance.
