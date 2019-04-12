# lamp

#### Table of Contents

1. [Overview](#overview)
2. [Module Description](#module-description)
3. [Setup](#setup)
    * [What lamp affects](#what-lamp-affects)
    * [Beginning with lamp](#beginning-with-lamp)
4. [Usage](#usage)
5. [Reference](#reference)
5. [Limitations](#limitations)
6. [Development](#development)
7. [Release Notes](#release)

## Overview

This module helps with automation of LAMP stack deploy environment on RedHat/CentOS/Debian/Ubuntu distributions. 

## Module Description

The main purpose of lamp module is the automation of puppetlabs apache and mysql modules which were chosen as the main modules for apache/mysql/php configuration and deploy. So all the next particular components configurations must be done inside apache and mysql modules itself, which installed as dependencies to lamp module. 

Look into apache/README.md and mysql/README.md descriptions for more configuration and usage technical details.

## Setup

### What lamp affects
                                                                                                                             
* configuration files and directories (created and written to)                                                               
    * **WARNING**: Configurations that are *not* managed by Puppet will be purged.                                           
* package/service/configuration files for Apache                                                                             
* Apache modules                                                                                                             
* virtual hosts                                                                                                              
* listened-to ports                                                                                                          
* `/etc/make.conf` on FreeBSD and Gentoo                                                                                     
* depends on module 'gentoo/puppet-portage' for Gentoo


### Beginning with lamp

 To get LAMP installed on your "mywebserver.dev.local" node lamp class needs to be added in site.pp configuration file:     
                                                                                                                            
    node 'mywebserver.dev.local' {                                                                                          
       include lamp                                                                                                         
    }   

## Usage

 Apache and MySQL installation configured inside the lamp::apache and lamp::mysql classes, where they could be disabled if required.
 
## Reference

 Though mpm 'worker' apache module is configured for Debian/Ubuntu distributions in puppetlabs-apache params by default, the lamp::apache class configured for mpm 'prefork' apache module usage for all distributions include Debian and Ubuntu because of apache php module installation requirement. But this configuration could be changed if necessary inside the lamp::apache '::apache': class parameters. Also php installation could be disabled with commented include ::apache::mod::php line in this class.


## Limitations

Module tested with RedHat/CentOS/Debian/Ubuntu operating systems, but it's additional puppetlabs components supposed to works with OracleLinux and Scientific distributions also.

## Development

This module could be used by others puppet users as helpful base for next CMS systems like Drupal, Joomla or Wordpress.

## Release Notes

Release 1.1.0.

LAMP deploy for RedHat/CentOS/Debian/Ubuntu operating systems.


