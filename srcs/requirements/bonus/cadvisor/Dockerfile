FROM debian:bookworm
# 1. Install wget and ca-certificates (crucial for HTTPS)
RUN apt-get update -y && \
    apt-get install -y wget ca-certificates && \
    rm -rf /var/lib/apt/lists/*
# 2. Download the binary (using the correct Linux-AMD64 version)
# I've updated this to v0.49.1 which is a very stable release
RUN wget https://github.com/google/cadvisor/releases/download/v0.49.1/cadvisor-v0.49.1-linux-amd64 -O /usr/bin/cadvisor
# 3. Set permissions
RUN chmod +x /usr/bin/cadvisor
EXPOSE 8080
CMD ["/usr/bin/cadvisor", "-logtostderr"]