FROM debian:bookworm

RUN apt-get update -y && apt-get upgrade -y && \
    apt-get install -y vsftpd

# Copy our configuration and the start script
COPY conf/vsftpd.conf /etc/vsftpd.conf
COPY tools/setup.sh /usr/local/bin/setup.sh
RUN chmod +x /usr/local/bin/setup.sh

# FTP needs these ports: 21 (commands) and 21100-21110 (data)
EXPOSE 21 21100-21110

CMD ["/usr/local/bin/setup.sh"]