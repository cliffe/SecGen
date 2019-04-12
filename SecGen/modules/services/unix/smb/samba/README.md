# Puppet module: samba

## DEPRECATION NOTICE
This module is no more actively maintained and will hardly be updated.

Please find an alternative module from other authors or consider [Tiny Puppet](https://github.com/example42/puppet-tp) as replacement.

If you want to maintain this module, contact [Alessandro Franceschi](https://github.com/alvagante)


This is a Puppet module for samba based on the second generation layout ("NextGen") of Example42 Puppet Modules.

Made by Alessandro Franceschi / Lab42

Official site: http://www.example42.com

Official git repository: http://github.com/example42/puppet-samba

Released under the terms of Apache 2 License.

This module requires functions provided by the Example42 Puppi module (you need it even if you don't use and install Puppi)

For detailed info about the logic and usage patterns of Example42 modules check the DOCS directory on Example42 main modules set.


## USAGE - Basic management

* Install samba with default settings

        class { 'samba': }

* Install a specific version of samba package

        class { 'samba':
          version => '1.0.1',
        }

* Disable samba service.

        class { 'samba':
          disable => true
        }

* Remove samba package

        class { 'samba':
          absent => true
        }

* Enable auditing without without making changes on existing samba configuration *files*

        class { 'samba':
          audit_only => true
        }


## USAGE - Overrides and Customizations
* Use custom sources for main config file 

        class { 'samba':
          source => [ "puppet:///modules/example42/samba/samba.conf-${hostname}" , "puppet:///modules/example42/samba/samba.conf" ], 
        }


* Use custom source directory for the whole configuration dir

        class { 'samba':
          source_dir       => 'puppet:///modules/example42/samba/conf/',
          source_dir_purge => false, # Set to true to purge any existing file not present in $source_dir
        }

* Use custom template for main config file. Note that template and source arguments are alternative. 

        class { 'samba':
          template => 'example42/samba/samba.conf.erb',
        }

* Automatically include a custom subclass

        class { 'samba':
          my_class => 'example42::my_samba',
        }


## USAGE - Example42 extensions management 
* Activate puppi (recommended, but disabled by default)

        class { 'samba':
          puppi    => true,
        }

* Activate puppi and use a custom puppi_helper template (to be provided separately with a puppi::helper define ) to customize the output of puppi commands 

        class { 'samba':
          puppi        => true,
          puppi_helper => 'myhelper', 
        }

* Activate automatic monitoring (recommended, but disabled by default). This option requires the usage of Example42 monitor and relevant monitor tools modules

        class { 'samba':
          monitor      => true,
          monitor_tool => [ 'nagios' , 'monit' , 'munin' ],
        }

* Activate automatic firewalling. This option requires the usage of Example42 firewall and relevant firewall tools modules

        class { 'samba':       
          firewall      => true,
          firewall_tool => 'iptables',
          firewall_src  => '10.42.0.0/24',
          firewall_dst  => $ipaddress_eth0,
        }



[![Build Status](https://travis-ci.org/example42/puppet-samba.png?branch=master)](https://travis-ci.org/example42/puppet-samba)
