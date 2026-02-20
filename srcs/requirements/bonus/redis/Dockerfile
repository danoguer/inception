# 1. Base OS
FROM debian:bookworm
# 2. Install Redis Server
RUN apt-get update -y && apt-get upgrade -y && \
    apt-get install -y redis-server
# 3. Configure Redis for Docker
# - Comment out "bind 127.0.0.1" so it listens to all interfaces (0.0.0.0)
# - Set max memory to 256mb (to prevent it from eating your RAM)
# - Set eviction policy to delete old keys when full
# - Turn off protected mode so WordPress can connect
RUN sed -i "s|bind 127.0.0.1|#bind 127.0.0.1|g" /etc/redis/redis.conf && \
    sed -i "s|# maxmemory <bytes>|maxmemory 256mb|g" /etc/redis/redis.conf && \
    sed -i "s|# maxmemory-policy noeviction|maxmemory-policy allkeys-lru|g" /etc/redis/redis.conf && \
    sed -i "s|protected-mode yes|protected-mode no|g" /etc/redis/redis.conf
# 4. Open the default Redis port
EXPOSE 6379
# 5. Start Redis
CMD ["redis-server", "--protected-mode", "no"]