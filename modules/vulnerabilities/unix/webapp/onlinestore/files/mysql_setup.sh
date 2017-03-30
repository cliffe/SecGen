#!/bin/sh

echo "CREATE USER '${1}'@'localhost' IDENTIFIED BY '${2}';"| mysql --force
echo "GRANT ALL PRIVILEGES ON * . * TO '${1}'@'localhost';"| mysql --force
echo "CREATE DATABASE csecvm;"| mysql --user=${1} --password=${2} --force
mysql --force --user=${1} --password=${2} csecvm < ./csecvm.sql
