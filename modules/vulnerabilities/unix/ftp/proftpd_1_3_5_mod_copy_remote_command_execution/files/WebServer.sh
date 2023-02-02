#!/bin/bash
while :
    do
        sudo busybox httpd -h /var/www/html/
        sleep 300000;
done