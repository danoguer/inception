# 1. The Base OS
FROM debian:bookworm

# 2. Install NGINX and OpenSSL (for the certificates)
RUN apt-get update -y && \
    apt-get upgrade -y && \
    apt-get install -y nginx openssl && \
    rm -rf /var/lib/apt/lists/*
# 3. Create a folder to store the SSL certificates securely
RUN mkdir -p /etc/nginx/ssl

# 4. Generate the Self-Signed SSL Certificate
# This creates a public key (.crt) and a private key (.key) valid for 365 days.
# The 'CN' (Common Name) is set to your specific 42 login domain.
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -out /etc/nginx/ssl/inception.crt \
    -keyout /etc/nginx/ssl/inception.key \
    -subj "/C=ES/ST=Madrid/L=Madrid/O=42/OU=42/CN=danoguer.42.fr/UID=danoguer"

# 5. Create the folder where the website files will live
RUN mkdir -p /var/www/html

# 6. Copy our custom NGINX configuration rules
COPY conf/nginx.conf /etc/nginx/nginx.conf

# 7. Start NGINX in the foreground so the container doesn't crash (PID 1)
CMD ["nginx", "-g", "daemon off;"]