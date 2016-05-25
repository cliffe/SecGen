# == Class: lamp
#
# The main lamp class created for automatically deploy LAMP (Linux/Apache/MySQL/PHP) complex environment on web server. 
# This class uses additional puppetlabs-apache and puppetlabs-mysql modules.
# All next possible required environment configuration changes must be done in this parent apache and mysql modules itself.
#
# === Parameters
#
# List of classes runs from lamp
#
# include ::lamp::apache
#   Deploy apache web server, with configured php
#
# include ::lamp::mysql
#   Deploy mysql database server
#
# Notes: any from this components could be commented if you don't need to install all of them
#
#
# === Examples
#
# To get LAMP installed on your "mywebserver.dev.local" node lamp class needs to be added in site.pp configuration file:
#
#    node 'mywebserver.dev.local' {
#       include lamp
#    }
#
#
# === Authors
#
# Alexander Golovin, https://github.com/alexggolovin
#
# === Copyright
#
# Copyright 2015 alexggolovin
#

class lamp {

include ::lamp::apache
include ::lamp::mysql

}



