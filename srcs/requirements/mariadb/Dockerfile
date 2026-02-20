# 1. The Base OS (The subject requires Debian penultimate stable or Alpine)
FROM debian:bookworm

# 2. Update the package list and install MariaDB
RUN apt-get update -y && apt-get upgrade -y && \
    apt-get install -y mariadb-server

# 3. Copy our custom configuration file into the container
COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf

# 4. Copy our initialization script into the container
COPY tools/setup.sh /usr/local/bin/setup.sh

# 5. Give the script permission to be executed
RUN chmod +x /usr/local/bin/setup.sh

# 6. The command that runs when the container starts
CMD ["/usr/local/bin/setup.sh"]