# Inception

A production-grade microservices infrastructure built from scratch as part of the 42 advanced curriculum. Every container is engineered from a bare Debian Bookworm base — no pre-built application images.

The full technical write-up covering the engineering process and decisions behind this project is available at [My 42 Journey — Inception Series](https://42-journey.hashnode.dev/series/inception).

---

## Architecture

Only NGINX is exposed to the outside world. All other services communicate exclusively over internal Docker networks.

```
[ Public Internet ]
        │
        ▼  Port 443 — HTTPS / TLS 1.3
┌───────────────────┐
│      NGINX        │  SSL termination, reverse proxy, static routing
└───┬───────┬───┬───┘
    │       │   │
 FastCGI  Proxy Proxy
    │       │   │
    ▼       ▼   ▼
┌─────────┐ ┌────────┐ ┌──────────┐
│WordPress│ │Adminer │ │cAdvisor  │
│+ PHP-FPM│ │        │ │          │
└────┬────┘ └───┬────┘ └──────────┘
     │          │
     ▼          ▼
┌─────────┐ ┌──────────┐
│  Redis  │ │  MariaDB │
└─────────┘ └──────────┘
     ▲            ▲
     └── Volumes ─┘
```

**Request flow:**
1. Client connects to `https://danoguer.42.fr`
2. NGINX terminates TLS and routes the request
3. PHP traffic is forwarded to WordPress via FastCGI on port 9000
4. WordPress checks Redis for a cache hit; on miss, queries MariaDB on port 3306

---

## Services

| Service | Technology | Role |
|---|---|---|
| Reverse Proxy | NGINX | Single entry point. Handles TLS 1.2/1.3, path-based routing, and static file serving |
| Application | WordPress + PHP-FPM 8.2 | PHP processing via dedicated FPM workers, hardened at build time |
| Database | MariaDB | Relational storage, unreachable from the host, internal network only |
| Cache | Redis | In-memory object cache, reduces repeated DB queries |
| File Transfer | vsftpd | FTPS access mapped directly to the WordPress volume |
| DB Manager | Adminer | Lightweight database UI, proxied behind NGINX |
| Monitoring | cAdvisor | Scrapes real-time CPU, memory, and network I/O metrics from cgroups |
| Static Site | HTML/CSS | Portfolio page served from NGINX, demonstrates multi-root routing |

---

## Design Decisions

**No pre-built images.** Every service starts from a clean Debian Bookworm or Alpine base. Standard DockerHub application stacks (`image: wordpress`) are not used.

**Isolated networks.** Services are segmented into functional layers via custom Docker bridge networks. The database layer has no route to the internet. Only NGINX binds a host port.

**Stateless containers.** Application and database state is persisted through Docker Volumes mounted at defined host paths. Containers can be rebuilt without data loss.

**Least privilege.** Service processes run as non-root accounts. PHP workers run as `www-data`; no daemon runs with unnecessary system capabilities.

---

## Setup

### Prerequisites

- Linux (Debian/Ubuntu recommended)
- Docker Engine v20.10+, Docker Compose v2.0+, GNU Make
- `sudo` access for the DNS step

### Steps

**1. DNS**
```bash
echo "127.0.0.1 danoguer.42.fr" | sudo tee -a /etc/hosts
```

**2. Environment**

Copy `.env.example` to `srcs/.env` and fill in your values:

```env
DOMAIN_NAME=danoguer.42.fr
SQL_USER=db_operator
SQL_PASSWORD=
SQL_ROOT_PASSWORD=
SQL_DATABASE=wordpress_prod
WP_ADMIN_USER=cloud_admin
WP_ADMIN_PASSWORD=
WP_ADMIN_EMAIL=danoguer@student.42madrid.com
WP_USER=
WP_USER_PASSWORD=
FTP_USER=ftp_operator
FTP_PASSWORD=
```

**3. Build and run**
```bash
make
docker ps   # verify all containers are up
```

> Data directories are created automatically by `make` at `/home/danoguer/data_bonus/`.

---

## Endpoints

| Service | URL | Protocol |
|---|---|---|
| WordPress | `https://danoguer.42.fr` | TLS 1.3 |
| Static site | `https://danoguer.42.fr/static` | TLS 1.3 |
| Monitoring | `https://danoguer.42.fr/cadvisor` | TLS 1.3 |
| DB admin | `https://danoguer.42.fr/adminer` | TLS 1.3 |
| FTP | `ftps://danoguer.42.fr` | FTPS |

> The SSL certificate is self-signed. Browsers will show a security warning on first visit — proceed via **Advanced → Continue**.

---

## Makefile Commands

```bash
make            # Build and start all services (alias: make up)
make down       # Stop and remove containers, preserve volumes and data
make clean      # Stop containers and prune unused Docker images
make fclean     # Full reset: removes containers, images, and all persistent data
make re         # fclean + full rebuild
```

---

## Notes

AI tooling (Gemini) was used during development for debugging and configuration review, consistent with standard engineering practice.
