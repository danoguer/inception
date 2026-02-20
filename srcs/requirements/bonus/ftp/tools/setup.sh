#!/bin/bash
# Create the secure_chroot_dir (vsftpd will OOPS if this doesn't exist)
mkdir -p /var/run/vsftpd/empty
# Create the user if it doesn't exist
if ! id -u "$FTP_USER" >/dev/null 2>&1; then
    useradd -m $FTP_USER
    echo "$FTP_USER:$FTP_PASSWORD" | chpasswd  
    # Ensure the user can actually write to the shared volume
    chown -R $FTP_USER:$FTP_USER /var/www/html
fi
echo "FTP Server starting on port 21..."
# Run vsftpd with the config file
exec vsftpd /etc/vsftpd.conf