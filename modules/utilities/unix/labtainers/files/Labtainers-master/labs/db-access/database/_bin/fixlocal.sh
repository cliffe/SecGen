#!/bin/bash
#
#  This script will be run after parameterization has completed, e.g., 
#  use this to compile source code that has been parameterized.
#  The container user password will be passed as the first argument,
#  (the user ID is the second parameter)
#  If this script is to use sudo and the sudoers for the lab
#  does not permit nopassword, then use:
#  echo $1 | sudo -S the-command
#
#  If you issue commands herein to start services, and those services
#  have unit files prescribing their being started after the
#  waitparam.service, then first create the flag directory that
#  waitparam sleeps on:
#
#   PERMLOCKDIR=/var/labtainer/did_param
#   echo $1 | sudo -S mkdir -p "$PERMLOCKDIR"

checkMsqlService() {
    # Starting the MySQL service:
    sudo systemctl start mysql

    # Writing the status of MySQL service to an arbitrary .txt file
    systemctl status mysql > /tmp/mysqllog.txt
    sleep 1
}

# Counter for loop to time out after 10 seconds if service doesnt start
x=0

# Execute check for mysql service 
checkMsqlService

# -m1 is the first match found in the arbitrary .txt file
while ! grep -m1 'active (running)' < /tmp/mysqllog.txt || x < 10
do
    checkMsqlService
    x=$(( x+1))
    #post command to run separate script here
    
done

# Setting the user-password pair for root
echo $1 | mysql -u root -e "SET PASSWORD FOR 'root'@'localhost' = PASSWORD('pass4root')"

# Populating the database
# ***Place custom .sql script as a substitute for db.sql
echo $1 | mysql -u root -ppass4root < $HOME/MYCO.sql

# Creating users
echo $1 | mysql -u root -ppass4root < $HOME/users.sql
