#!/bin/sh
sudo mkdir -p /usr/share/empty/	

sudo mkdir -p /var/ftp/

sudo chown root.root /var/ftp
sudo chmod og-w /var/ftp

sudo cp vsftpd /usr/local/sbin/vsftpd
sudo cp vsftpd.conf.5 /usr/local/man/man5
sudo cp vsftpd.8 /usr/local/man/man8

sudo cp vsftpd.conf /etc