# Inception

A multi-service infrastructure built entirely from scratch — no pre-built application images. Every container starts from a bare Debian Bookworm base and is assembled through custom Dockerfiles, shell provisioning scripts, and a single Docker Compose orchestration layer.

The project demonstrates hands-on work across container networking, service isolation, TLS configuration, caching architecture, and startup dependency management.

Full technical write-up: [Inception Series — 42 Journey Blog](https://42-journey.hashnode.dev/series/inception)

---

## What it covers

- Reverse proxy and TLS termination with NGINX (TLS 1.2/1.3, self-signed certificates)
- PHP application serving via FastCGI (WordPress + PHP-FPM 8.2)
- Relational storage with MariaDB, network-isolated from the host
- Object caching with Redis to reduce database query load
- Startup dependency ordering via Docker health checks (`mysqladmin ping`)
- Idempotent container initialisation — restarts preserve existing data
- Principle of least privilege — no service process runs as root
- Bind mount persistence — data survives full container teardown
- Observability via cAdvisor (CPU, memory, network I/O per container)
- Secure file access via FTPS (vsftpd)

---

## Architecture

NGINX is the sole entry point. All other services are unreachable from outside the Docker network.

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
2. NGINX terminates TLS and routes the request by path
3. PHP traffic is forwarded to WordPress via FastCGI on port 9000
4. WordPress checks Redis for a cache hit; on miss, queries MariaDB on port 3306

---

## Services

| Service | Technology | Role |
|---|---|---|
| Reverse Proxy | NGINX | Single entry point. TLS 1.2/1.3, path-based routing, static file serving |
| Application | WordPress + PHP-FPM 8.2 | PHP processing via dedicated FPM workers, hardened at build time |
| Database | MariaDB | Relational storage, unreachable from the host, internal network only |
| Cache | Redis | In-memory object cache, reduces repeated DB queries |
| File Transfer | vsftpd | FTPS access mapped directly to the WordPress volume |
| DB Manager | Adminer | Lightweight database UI, proxied behind NGINX |
| Monitoring | cAdvisor | Real-time CPU, memory, and network I/O metrics from cgroups |
| Static Site | HTML/CSS | Portfolio page served from NGINX, demonstrates multi-root routing |

---

## Design Decisions

**No pre-built images.** Every service starts from a clean Debian Bookworm or Alpine base. Standard DockerHub application stacks (`image: wordpress`) are not used. This forced a ground-up understanding of how each service is installed, configured, and hardened.

**Isolated networks.** Services are segmented via custom Docker bridge networks. The database layer has no route to the internet. Only NGINX binds a host port.

**Stateless containers, stateful data.** Containers are fully ephemeral. State is persisted through bind mounts to defined host paths, so a complete container teardown loses nothing.

**Least privilege.** Service processes run as non-root accounts. PHP workers run as `www-data`; no daemon carries unnecessary system capabilities.

**Dependency-ordered startup.** WordPress waits for MariaDB to pass a `mysqladmin ping` health check before attempting to connect, eliminating the race condition that causes silent failures on first boot.

---

## Setup

### Prerequisites

- Linux — Debian/Ubuntu recommended
- Docker Engine v24.0+, Docker Compose v2.20+, GNU Make
- `sudo` access for the DNS step

### Steps

**1. DNS**
```bash
echo "127.0.0.1 danoguer.42.fr" | sudo tee -a /etc/hosts
```

**2. Environment**

Create `srcs/.env` from the template below. All variables are required.

```env
DOMAIN_NAME=danoguer.42.fr

SQL_USER=
SQL_PASSWORD=
SQL_ROOT_PASSWORD=
SQL_DATABASE=

WP_ADMIN_USER=
WP_ADMIN_PASSWORD=
WP_ADMIN_EMAIL=
WP_USER=
WP_USER_PASSWORD=

FTP_USER=
FTP_PASSWORD=
```

**3. Build and run**
```bash
make
docker ps
```

Data directories are created automatically at `/home/danoguer/data_bonus/`.

---

## Endpoints

| Service | URL |
|---|---|
| WordPress | `https://danoguer.42.fr` |
| WordPress Admin | `https://danoguer.42.fr/wp-admin` |
| Static site | `https://danoguer.42.fr/portfolio` |
| Monitoring | `https://danoguer.42.fr/cadvisor` |
| DB admin | `https://danoguer.42.fr/adminer` |
| FTP | `ftps://danoguer.42.fr` |

> SSL certificates are self-signed. On first visit, proceed via **Advanced → Continue**.

---

## Makefile

```bash
make            # Build and start all services
make down       # Stop containers, preserve data
make clean      # Stop containers and prune unused images
make fclean     # Full reset — removes containers, images, and all persistent data
make re         # fclean + full rebuild
```

---

## Further Reading

For implementation details — bind mount layout, idempotent initialisation logic, health check configuration, and debugging commands — see [DEV.md](./DEV.md).
