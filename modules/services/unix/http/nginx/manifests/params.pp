class nginx::params {
  ### Operating System Configuration
  ## This is my hacky... no hiera system. Oh well. :)
  $_module_defaults = {
    'conf_dir'    => '/etc/nginx',
    'daemon_user' => 'nginx',
    'pid'         => '/var/run/nginx.pid',
    'root_group'  => 'root',
    'log_dir'     => '/var/log/nginx',
    'run_dir'     => '/var/nginx',
    'package_name' => 'nginx',
    'manage_repo'  => false,
  }
  case $::osfamily {
    'ArchLinux': {
      $_module_os_overrides = {
        'pid'         => false,
        'daemon_user' => 'http',
      }
    }
    'Debian': {
      if ($::operatingsystem == 'ubuntu' and $::lsbdistcodename in ['lucid', 'precise', 'trusty'])
      or ($::operatingsystem == 'debian' and $::operatingsystemmajrelease in ['6', '7', '8']) {
        $_module_os_overrides = {
          'manage_repo' => true,
          'daemon_user' => 'www-data',
        }
      } else {
        $_module_os_overrides = {
          'daemon_user' => 'www-data',
        }
      }
    }
    'FreeBSD': {
      $_module_os_overrides = {
        'conf_dir'    => '/usr/local/etc/nginx',
        'daemon_user' => 'www',
        'root_group'  => 'wheel',
      }
    }
    'Gentoo': {
      $_module_os_overrides = {
        'package_name' => 'www-servers/nginx',
      }
    }
    'RedHat': {
      if ($::operatingsystem in ['RedHat', 'CentOS'] and $::operatingsystemmajrelease in ['5', '6', '7']) {
        $_module_os_overrides = {
          'manage_repo' => true,
        }
      }
    }
    'Solaris': {
      $_module_os_overrides = {
        'daemon_user'  => 'webservd',
        'package_name' => undef,
      }
    }
    'OpenBSD': {
      $_module_os_overrides = {
        'daemon_user' => 'www',
        'root_group'  => 'wheel',
        'log_dir'     => '/var/www/logs',
        'run_dir'     => '/var/www',
      }
    }
    default: {
      ## For cases not covered in $::osfamily
      case $::operatingsystem {
        'SmartOS': {
          $_module_os_overrides = {
            'conf_dir'    => '/usr/local/etc/nginx',
            'daemon_user' => 'www',
          }
        }
        default: { $_module_os_overrides = {} }
      }
    }
  }

  $_module_parameters = merge($_module_defaults, $_module_os_overrides)
  ### END Operating System Configuration

  ### Referenced Variables
  $conf_dir              = $_module_parameters['conf_dir']
  $log_dir               = $_module_parameters['log_dir']
  $run_dir               = $_module_parameters['run_dir']
  $temp_dir              = '/tmp'
  $pid                   = $_module_parameters['pid']

  $client_body_temp_path = "${run_dir}/client_body_temp"
  $daemon_user           = $_module_parameters['daemon_user']
  $global_owner          = 'root'
  $global_group          = $_module_parameters['root_group']
  $global_mode           = '0644'
  $http_access_log       = "${log_dir}/access.log"
  $manage_repo           = $_module_parameters['manage_repo']
  $nginx_error_log       = "${log_dir}/error.log"
  $root_group            = $_module_parameters['root_group']
  $package_name          = $_module_parameters['package_name']
  $proxy_temp_path       = "${run_dir}/proxy_temp"
  $sites_available_owner = 'root'
  $sites_available_group = $_module_parameters['root_group']
  $sites_available_mode  = '0644'
  $super_user            = true
  ### END Referenced Variables
}
