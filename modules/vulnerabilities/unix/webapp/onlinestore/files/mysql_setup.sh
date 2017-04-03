#!/bin/sh

USERNAME=${1}
PASSWORD=${2}
token=${3}

echo "CREATE USER '${USERNAME}'@'localhost' IDENTIFIED BY '${PASSWORD}';"| mysql --force
echo "GRANT ALL PRIVILEGES ON * . * TO '${USERNAME}'@'localhost';"| mysql --force
echo "CREATE DATABASE csecvm;"| mysql --user=${USERNAME} --password=${PASSWORD} --force
mysql --force --user=${USERNAME} --password=${PASSWORD} csecvm < ./csecvm.sql

echo "USE csecvm; INSERT INTO token VALUES ('${token}');" |  mysql --force --user=${USERNAME} --password=${PASSWORD}