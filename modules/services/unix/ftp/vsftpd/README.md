# Puppet module: vsftpd

This is a Puppet module for vsftpd based on the second generation layout ("NextGen") of Example42 Puppet Modules.

Made by Alessandro Franceschi / Lab42

Official site: http://www.example42.com

Official git repository: http://github.com/example42/puppet-vsftpd

Released under the terms of Apache 2 License.

This module requires functions provided by the Example42 Puppi module (you need it even if you don't use and install Puppi)

For detailed info about the logic and usage patterns of Example42 modules check the DOCS directory on Example42 main modules set.

## USAGE - Basic management

* Install vsftpd with default settings

        class { 'vsftpd': }

* You can use a template to manage different vsftpd's parameters. By default [*template*] is empty, so the default distribution configuration is used. 

  A template is provided (if you want to use it), covering most of the available parameters. Just set template to 'vsftpd/vsftpd.conf.erb' and check in the params.pp and init.pp files for the available parameters.

        class { 'vsftpd':
          template         => 'vsftpd/vsftpd.conf.erb',
          anonymous_enable => false,
          ftpd_banner      => 'Aloha stranger!',
        }

* Install a specific version of vsftpd package

        class { 'vsftpd':
          version => '1.0.1',
        }

* Disable vsftpd service.

        class { 'vsftpd':
          disable => true
        }

* Remove vsftpd package

        class { 'vsftpd':
          absent => true
        }

* Enable auditing without without making changes on existing vsftpd configuration files

        class { 'vsftpd':
          audit_only => true
        }


## USAGE - Overrides and Customizations
* Use custom sources for main config file 

        class { 'vsftpd':
          source => [ "puppet:///modules/lab42/vsftpd/vsftpd.conf-${hostname}" , "puppet:///modules/lab42/vsftpd/vsftpd.conf" ], 
        }


* Use custom source directory for the whole configuration dir

        class { 'vsftpd':
          source_dir       => 'puppet:///modules/lab42/vsftpd/conf/',
          source_dir_purge => false, # Set to true to purge any existing file not present in $source_dir
        }

* Use custom template for main config file. Note that template and source arguments are alternative. 

        class { 'vsftpd':
          template => 'example42/vsftpd/vsftpd.conf.erb',
        }

* Automatically include a custom subclass

        class { 'vsftpd':
          my_class => 'vsftpd::example42',
        }


## USAGE - Example42 extensions management 
* Activate puppi (recommended, but disabled by default)

        class { 'vsftpd':
          puppi    => true,
        }

* Activate puppi and use a custom puppi_helper template (to be provided separately with a puppi::helper define ) to customize the output of puppi commands 

        class { 'vsftpd':
          puppi        => true,
          puppi_helper => 'myhelper', 
        }

* Activate automatic monitoring (recommended, but disabled by default). This option requires the usage of Example42 monitor and relevant monitor tools modules

        class { 'vsftpd':
          monitor      => true,
          monitor_tool => [ 'nagios' , 'monit' , 'munin' ],
        }

* Activate automatic firewalling. This option requires the usage of Example42 firewall and relevant firewall tools modules

        class { 'vsftpd':       
          firewall      => true,
          firewall_tool => 'iptables',
          firewall_src  => '10.42.0.0/24',
          firewall_dst  => $ipaddress_eth0,
        }


[![Build Status](https://travis-ci.org/example42/puppet-vsftpd.png?branch=master)](https://travis-ci.org/example42/puppet-vsftpd)
