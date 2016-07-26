# PHP globals class
#
# === Parameters
#
# [*php_version*]
#   The version of php.
#
# [*config_root*]
#   The configuration root directory.
#
# [*fpm_pid_file*]
#   Path to pid file for fpm

class php::globals (
  $php_version  = undef,
  $config_root  = undef,
  $fpm_pid_file = undef,
) {
  if $php_version != undef {
    validate_re($php_version, '^[57].[0-9]')
  }
  if $config_root != undef {
    validate_absolute_path($config_root)
  }

  if $fpm_pid_file != undef {
    validate_absolute_path($fpm_pid_file)
  }

  $default_php_version = $::osfamily ? {
    'Debian' => $::operatingsystem ? {
      'Ubuntu' => $::operatingsystemrelease ? {
        /^(16.04)$/ => '7.0',
        default => '5.6',
      },
      default => '5.x',
    },
    default => '5.x',
  }

  $globals_php_version = pick($php_version, $default_php_version)

  case $::osfamily {
    'Debian': {
      if $::operatingsystem == 'Ubuntu' {
        case $globals_php_version {
          /^5\.4/: {
            $default_config_root  = '/etc/php5'
            $default_fpm_pid_file = "/var/run/php/php${globals_php_version}-fpm.pid"
            $fpm_error_log        = '/var/log/php5-fpm.log'
            $fpm_service_name     = 'php5-fpm'
            $ext_tool_enable      = '/usr/sbin/php5enmod'
            $ext_tool_query       = '/usr/sbin/php5query'
            $package_prefix       = 'php5-'
          }
          /^5\.5/: {
            $default_config_root  = "/etc/php/${globals_php_version}"
            $default_fpm_pid_file = "/var/run/php/php${globals_php_version}-fpm.pid"
            $fpm_error_log        = "/var/log/php${globals_php_version}-fpm.log"
            $fpm_service_name     = "php${globals_php_version}-fpm"
            $ext_tool_enable      = "/usr/sbin/phpenmod -v ${globals_php_version}"
            $ext_tool_query       = "/usr/sbin/phpquery -v ${globals_php_version}"
            $package_prefix       = 'php5.5-'
          }
          /^5\.6/: {
            $default_config_root  = "/etc/php/${globals_php_version}"
            $default_fpm_pid_file = "/var/run/php/php${globals_php_version}-fpm.pid"
            $fpm_error_log        = "/var/log/php${globals_php_version}-fpm.log"
            $fpm_service_name     = "php${globals_php_version}-fpm"
            $ext_tool_enable      = "/usr/sbin/phpenmod -v ${globals_php_version}"
            $ext_tool_query       = "/usr/sbin/phpquery -v ${globals_php_version}"
            $package_prefix       = 'php5.6-'
          }
          /^7/: {
            $default_config_root  = "/etc/php/${globals_php_version}"
            $default_fpm_pid_file = "/var/run/php/php${globals_php_version}-fpm.pid"
            $fpm_error_log        = "/var/log/php${globals_php_version}-fpm.log"
            $fpm_service_name     = "php${globals_php_version}-fpm"
            $ext_tool_enable      = "/usr/sbin/phpenmod -v ${globals_php_version}"
            $ext_tool_query       = "/usr/sbin/phpquery -v ${globals_php_version}"
            $package_prefix       = 'php7.0-'
          }
          default: {
            $default_config_root  = "/etc/php/${globals_php_version}"
            $default_fpm_pid_file = "/var/run/php/php${globals_php_version}-fpm.pid"
            $fpm_error_log        = "/var/log/php${globals_php_version}-fpm.log"
            $fpm_service_name     = "php${globals_php_version}-fpm"
            $ext_tool_enable      = "/usr/sbin/phpenmod -v ${globals_php_version}"
            $ext_tool_query       = "/usr/sbin/phpquery -v ${globals_php_version}"
            $package_prefix       = 'php-'
          }
        }
      } else {
        case $globals_php_version {
          /^7/: {
            $default_config_root  = "/etc/php/${globals_php_version}"
            $default_fpm_pid_file = "/var/run/php/php${globals_php_version}-fpm.pid"
            $fpm_error_log        = "/var/log/php${globals_php_version}-fpm.log"
            $fpm_service_name     = "php${globals_php_version}-fpm"
            $ext_tool_enable      = "/usr/sbin/phpenmod -v ${globals_php_version}"
            $ext_tool_query       = "/usr/sbin/phpquery -v ${globals_php_version}"
            $package_prefix       = 'php7.0-'
          }
          default: {
            $default_config_root  = '/etc/php5'
            $default_fpm_pid_file = '/var/run/php5-fpm.pid'
            $fpm_error_log        = '/var/log/php5-fpm.log'
            $fpm_service_name     = 'php5-fpm'
            $ext_tool_enable      = '/usr/sbin/php5enmod'
            $ext_tool_query       = '/usr/sbin/php5query'
            $package_prefix       = 'php5-'
          }
        }
      }
    }
    'Suse': {
      case $globals_php_version {
        /^7/: {
          $default_config_root  = '/etc/php7'
          $package_prefix       = 'php7-'
          $default_fpm_pid_file = '/var/run/php7-fpm.pid'
          $fpm_error_log        = '/var/log/php7-fpm.log'
        }
        default: {
          $default_config_root  = '/etc/php5'
          $package_prefix       = 'php5-'
          $default_fpm_pid_file = '/var/run/php5-fpm.pid'
          $fpm_error_log        = '/var/log/php5-fpm.log'
        }
      }
    }
    'RedHat': {
      $default_config_root  = '/etc/php.d'
      $default_fpm_pid_file = '/var/run/php-fpm/php-fpm.pid'
    }
    'FreeBSD': {
      $default_config_root  = '/usr/local/etc'
      $default_fpm_pid_file = '/var/run/php-fpm.pid'
    }
    default: {
      fail("Unsupported osfamily: ${::osfamily}")
    }
  }

  $globals_config_root = pick($config_root, $default_config_root)

  $globals_fpm_pid_file = pick($fpm_pid_file, $default_fpm_pid_file)
}
