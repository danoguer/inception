# DEV.md — Implementation Notes

This document covers the internal mechanics of the infrastructure: data persistence, startup sequencing, and debugging. For a high-level overview, see [README.md](./README.md).

---

## Prerequisites

- Linux — Debian 12 Bookworm recommended
- Docker Engine v24.0+
- Docker Compose v2.20+ (V2 plugin syntax: `docker compose`)
- GNU Make

---

## Environment Variables

Create `srcs/.env` before running `make`. Docker Compose reads this file and injects variables into containers at build time. No defaults are assumed — all fields are required.

```env
# Domain
DOMAIN_NAME=example.42.fr

# Database
SQL_USER=
SQL_PASSWORD=
SQL_ROOT_PASSWORD=
SQL_DATABASE=

# WordPress
WP_ADMIN_USER=
WP_ADMIN_PASSWORD=
WP_ADMIN_EMAIL=
WP_USER=
WP_USER_PASSWORD=

# FTP
FTP_USER=
FTP_PASSWORD=
```

---

## Makefile Reference

| Command | Behaviour |
|---|---|
| `make` / `make up` | Builds images and starts all containers in detached mode |
| `make down` | Stops and removes containers; data is preserved |
| `make clean` | `down` + prunes unused Docker images |
| `make fclean` | Full reset — removes containers, images, and all data under `data_bonus/` |
| `make re` | `fclean` followed by a full rebuild |

`make` also runs `mkdir -p` for the data directories on every invocation, so no manual host setup is required.

---

## Data Persistence

The project uses bind mounts rather than named Docker volumes. Data is tied to explicit host paths and survives complete container removal.

| Container path | Host path | Contents |
|---|---|---|
| `/var/lib/mysql` | `/home/danoguer/data_bonus/mariadb` | SQL tables, logs, binary logs |
| `/var/www/html` | `/home/danoguer/data_bonus/wordpress` | PHP scripts, plugins, media uploads |

### Idempotent initialisation

Both stateful services guard against re-initialising on restart:

**MariaDB** — `setup.sh` checks for `/var/lib/mysql/mysql`. If absent, it runs the full bootstrap sequence (grants, database creation, user setup). If present, it skips directly to starting `mysqld`, preserving the existing dataset.

**WordPress** — `setup.sh` checks for `wp-config.php`. If present, it assumes a complete installation and only starts `php-fpm`. If absent, it runs the full WP-CLI install sequence, generates `wp-config.php`, and activates the Redis object cache plugin.

This means the stack can be stopped and restarted with `make down && make` without losing any data or re-running destructive setup steps.

---

## Startup Dependencies

WordPress requires MariaDB to be fully ready before attempting its first connection. Without explicit ordering, Docker starts containers in parallel and WordPress will fail silently if it reaches the connection step before MariaDB has finished initialising.

This is handled in `docker-compose.yml` with a health check on the MariaDB service:

```yaml
healthcheck:
  test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
  interval: 5s
  timeout: 3s
  retries: 10
```

Combined with:

```yaml
depends_on:
  mariadb:
    condition: service_healthy
```

WordPress only starts once MariaDB is passing the ping check, eliminating the race condition entirely.

---

## Debugging Reference

```bash
# Live logs for all services
docker compose logs -f

# Live logs for a specific service
docker logs -f mariadb

# Open a shell inside a running container
docker exec -it <container_name> /bin/bash

# Inspect internal network topology and container IPs
docker network inspect inception

# Check which containers are running and their health status
docker ps

# Remove all volumes manually (destructive — use only after make fclean)
docker volume rm $(docker volume ls -q)
```

---

## Common Failure Modes

**WordPress shows "Error establishing database connection" on first boot** — MariaDB health check may need more retries if the host is slow. Increase `retries` in the health check config.

**Permission denied writing to `/var/www/html`** — The bind mount host directory must be owned by the user running Docker, not root. Running `make fclean` and letting `make` recreate the directories fixes this.

**NGINX returns 502 Bad Gateway** — PHP-FPM is not yet listening on port 9000. Check `docker logs wordpress` for startup errors.

**cAdvisor shows no data** — Requires access to `/sys/fs/cgroup` on the host. Confirm Docker has cgroup v2 access on your system.
