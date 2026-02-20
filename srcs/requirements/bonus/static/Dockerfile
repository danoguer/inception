FROM debian:bookworm
RUN apt-get update -y && apt-get upgrade -y && \
    apt-get install -y nginx
# Copy our page into the standard NGINX folder
RUN rm -rf /var/www/html/*
COPY index.html /var/www/html/index.html
# Run NGINX in the foreground
CMD ["nginx", "-g", "daemon off;"]