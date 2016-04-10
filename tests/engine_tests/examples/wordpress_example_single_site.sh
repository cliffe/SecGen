#!/bin/bash
IPADDR=$(/sbin/ifconfig eth1 | grep 'inet addr:' | cut -d: -f2 | awk '{print $1}')

cd /var/www/wordpress &&
wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar &&
php wp-cli.phar core install --url=${IPADDR}/wordpress --title=wordpress --admin_user=root --admin_password=pa55w0rd --admin_email=test@test.net --skip-email --allow-root
