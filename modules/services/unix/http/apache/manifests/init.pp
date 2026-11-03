# Class: apache
#
# This class installs Apache
#
# Parameters:
#
# Actions:
#   - Install Apache
#   - Manage Apache service
#
# Requires:
#
# Sample Usage:
#
class apache (
  $apache_name                                                   = $::apache::params::apache_name,
  $service_name                                                  = $::apache::params::service_name,
  $default_mods                                                  = true,
  Boolean $default_vhost                                         = true,
  $default_charset                                               = undef,
  Boolean $default_confd_files                                   = true,
  Boolean $default_ssl_vhost                                     = false,
  $default_ssl_cert                                              = $::apache::params::default_ssl_cert,
  $default_ssl_key                                               = $::apache::params::default_ssl_key,
  $default_ssl_chain                                             = undef,
  $default_ssl_ca                                                = undef,
  $default_ssl_crl_path                                          = undef,
  $default_ssl_crl                                               = undef,
  $default_ssl_crl_check                                         = undef,
  $default_type                                                  = 'none',
  $dev_packages                                                  = $::apache::params::dev_packages,
  $ip                                                            = undef,
  Boolean $service_enable                                        = true,
  Boolean $service_manage                                        = true,
  $service_ensure                                                = 'running',
  $service_restart                                               = undef,
  $purge_configs                                                 = false,
  $purge_vhost_dir                                               = undef,
  $purge_vdir                                                    = false,
  $serveradmin                                                   = 'root@localhost',
  $sendfile                                                      = 'On',
  $error_documents                                               = false,
  $timeout                                                       = '120',
  $httpd_dir                                                     = $::apache::params::httpd_dir,
  $server_root                                                   = $::apache::params::server_root,
  $conf_dir                                                      = $::apache::params::conf_dir,
  $confd_dir                                                     = $::apache::params::confd_dir,
  $vhost_dir                                                     = $::apache::params::vhost_dir,
  $vhost_enable_dir                                              = $::apache::params::vhost_enable_dir,
  $mod_packages                                                  = $::apache::params::mod_packages,
  $vhost_include_pattern                                         = $::apache::params::vhost_include_pattern,
  $mod_dir                                                       = $::apache::params::mod_dir,
  $mod_enable_dir                                                = $::apache::params::mod_enable_dir,
  $mpm_module                                                    = $::apache::params::mpm_module,
  $lib_path                                                      = $::apache::params::lib_path,
  $conf_template                                                 = $::apache::params::conf_template,
  $servername                                                    = $::apache::params::servername,
  $pidfile                                                       = $::apache::params::pidfile,
  Optional[Stdlib::Absolutepath] $rewrite_lock                   = undef,
  Boolean $manage_user                                           = true,
  Boolean $manage_group                                          = true,
  $user                                                          = $::apache::params::user,
  $group                                                         = $::apache::params::group,
  $http_protocol_options                                         = $::apache::params::http_protocol_options,
  $supplementary_groups                                          = [],
  $keepalive                                                     = $::apache::params::keepalive,
  $keepalive_timeout                                             = $::apache::params::keepalive_timeout,
  $max_keepalive_requests                                        = $::apache::params::max_keepalive_requests,
  $limitreqfieldsize                                             = '8190',
  $logroot                                                       = $::apache::params::logroot,
  $logroot_mode                                                  = $::apache::params::logroot_mode,
  $log_level                                                     = $::apache::params::log_level,
  $log_formats                                                   = {},
  $ssl_file                                                      = undef,
  $ports_file                                                    = $::apache::params::ports_file,
  $docroot                                                       = $::apache::params::docroot,
  $apache_version                                                = $::apache::version::default,
  $server_tokens                                                 = 'OS',
  $server_signature                                              = 'On',
  $trace_enable                                                  = 'On',
  Optional[Enum['on', 'off', 'nodecode']] $allow_encoded_slashes = undef,
  $file_e_tag                                                    = undef,
  $package_ensure                                                = 'installed',
  Boolean $use_optional_includes                                 = $::apache::params::use_optional_includes,
  $use_systemd                                                   = $::apache::params::use_systemd,
  $mime_types_additional                                         = $::apache::params::mime_types_additional,
  $file_mode                                                     = $::apache::params::file_mode,
  $root_directory_options                                        = $::apache::params::root_directory_options,
  Boolean $root_directory_secured                                = false,
  $error_log                                                     = $::apache::params::error_log,
  $scriptalias                                                   = $::apache::params::scriptalias,
  $access_log_file                                               = $::apache::params::access_log_file,
  $overwrite_ports                                               = true, # TODO: Implement this as in wheezy apache
) inherits ::apache::params {

  $valid_mpms_re = $apache_version ? {
    '2.4'   => '(event|itk|peruser|prefork|worker)',
    default => '(event|itk|prefork|worker)'
  }

  if $::osfamily == 'RedHat' and $::apache::version::distrelease == '7' {
    # On redhat 7 the ssl.conf lives in /etc/httpd/conf.d (the confd_dir)
    # when all other module configs live in /etc/httpd/conf.modules.d (the
    # mod_dir). On all other platforms and versions, ssl.conf lives in the
    # mod_dir. This should maintain the expected location of ssl.conf
    $_ssl_file = $ssl_file ? {
      undef   => "${apache::confd_dir}/ssl.conf",
      default =>  $ssl_file
    }
  } else {
    $_ssl_file = $ssl_file ? {
      undef   => "${apache::mod_dir}/ssl.conf",
      default =>  $ssl_file
    }
  }

  if $mpm_module and $mpm_module != 'false' { # lint:ignore:quoted_booleans
    assert_type(Pattern[$valid_mpms_re], $mpm_module)
  }

  # NOTE: on FreeBSD it's mpm module's responsibility to install httpd package.
  # NOTE: the same strategy may be introduced for other OSes. For this, you
  # should delete the 'if' block below and modify all MPM modules' manifests
  # such that they include apache::package class (currently event.pp, itk.pp,
  # peruser.pp, prefork.pp, worker.pp).
  if $::osfamily != 'FreeBSD' {
    package { 'httpd':
      ensure => $package_ensure,
      name   => $apache_name,
      notify => Class['Apache::Service'],
    }
  }
  validate_re($sendfile, [ '^[oO]n$' , '^[oO]ff$' ])

  # declare the web server user and group
  # Note: requiring the package means the package ought to create them and not puppet
  if $manage_user {
    user { $user:
      ensure  => present,
      gid     => $group,
      groups  => $supplementary_groups,
      require => Package['httpd'],
    }
  }
  if $manage_group {
    group { $group:
      ensure  => present,
      require => Package['httpd'],
    }
  }

  validate_apache_log_level($log_level)

  class { '::apache::service':
    service_name    => $service_name,
    service_enable  => $service_enable,
    service_manage  => $service_manage,
    service_ensure  => $service_ensure,
    service_restart => $service_restart,
  }

  # Deprecated backwards-compatibility
  if $purge_vdir {
    warning('Class[\'apache\'] parameter purge_vdir is deprecated in favor of purge_configs')
    $purge_confd = $purge_vdir
  } else {
    $purge_confd = $purge_configs
  }

  # Set purge vhostd appropriately
  if $purge_vhost_dir == undef {
    $purge_vhostd = $purge_confd
  } else {
    $purge_vhostd = $purge_vhost_dir
  }

  Exec {
    path => '/bin:/sbin:/usr/bin:/usr/sbin',
  }

  exec { "mkdir ${confd_dir}":
    creates => $confd_dir,
    require => Package['httpd'],
  }
  file { $confd_dir:
    ensure  => directory,
    recurse => true,
    purge   => $purge_confd,
    force   => $purge_confd,
    notify  => Class['Apache::Service'],
    require => Package['httpd'],
  }

  if ! defined(File[$mod_dir]) {
    exec { "mkdir ${mod_dir}":
      creates => $mod_dir,
      require => Package['httpd'],
    }
    # Don't purge available modules if an enable dir is used
    $purge_mod_dir = $purge_configs and !$mod_enable_dir
    file { $mod_dir:
      ensure  => directory,
      recurse => true,
      purge   => $purge_mod_dir,
      notify  => Class['Apache::Service'],
      require => Package['httpd'],
      before  => Anchor['::apache::modules_set_up'],
    }
  }

  if $mod_enable_dir and ! defined(File[$mod_enable_dir]) {
    $mod_load_dir = $mod_enable_dir
    exec { "mkdir ${mod_enable_dir}":
      creates => $mod_enable_dir,
      require => Package['httpd'],
    }
    file { $mod_enable_dir:
      ensure  => directory,
      recurse => true,
      purge   => $purge_configs,
      notify  => Class['Apache::Service'],
      require => Package['httpd'],
    }
  } else {
    $mod_load_dir = $mod_dir
  }

  if ! defined(File[$vhost_dir]) {
    exec { "mkdir ${vhost_dir}":
      creates => $vhost_dir,
      require => Package['httpd'],
    }
    file { $vhost_dir:
      ensure  => directory,
      recurse => true,
      purge   => $purge_vhostd,
      notify  => Class['Apache::Service'],
      require => Package['httpd'],
    }
  }

  if $vhost_enable_dir and ! defined(File[$vhost_enable_dir]) {
    $vhost_load_dir = $vhost_enable_dir
    exec { "mkdir ${vhost_load_dir}":
      creates => $vhost_load_dir,
      require => Package['httpd'],
    }
    file { $vhost_enable_dir:
      ensure  => directory,
      recurse => true,
      purge   => $purge_vhostd,
      notify  => Class['Apache::Service'],
      require => Package['httpd'],
    }
  } else {
    $vhost_load_dir = $vhost_dir
  }

  if $overwrite_ports {
    concat { $ports_file:
      ensure  => present,
      owner   => 'root',
      group   => $::apache::params::root_group,
      mode    => $::apache::file_mode,
      notify  => Class['Apache::Service'],
      require => Package['httpd'],
    }
    concat::fragment { 'Apache ports header':
      target  => $ports_file,
      content => template('apache/ports_header.erb'),
    }
  }

  if $::apache::conf_dir and $::apache::params::conf_file {
    if $::osfamily == 'gentoo' {
      $error_documents_path = '/usr/share/apache2/error'
      if is_array($default_mods) {
        if versioncmp($apache_version, '2.4') >= 0 {
          if defined('apache::mod::ssl') {
            ::portage::makeconf { 'apache2_modules':
              content => concat($default_mods, [ 'authz_core', 'socache_shmcb' ]),
            }
          } else {
            ::portage::makeconf { 'apache2_modules':
              content => concat($default_mods, 'authz_core'),
            }
          }
        } else {
          ::portage::makeconf { 'apache2_modules':
            content => $default_mods,
          }
        }
      }

      file { [
        '/etc/apache2/modules.d/.keep_www-servers_apache-2',
        '/etc/apache2/vhosts.d/.keep_www-servers_apache-2',
      ]:
        ensure  => absent,
        require => Package['httpd'],
      }
    }

    $apxs_workaround = $::osfamily ? {
      'freebsd' => true,
      default   => false
    }

    # Template uses:
    # - $pidfile
    # - $user
    # - $group
    # - $logroot
    # - $error_log
    # - $sendfile
    # - $mod_dir
    # - $ports_file
    # - $confd_dir
    # - $vhost_dir
    # - $error_documents
    # - $error_documents_path
    # - $apxs_workaround
    # - $http_protocol_options
    # - $keepalive
    # - $keepalive_timeout
    # - $max_keepalive_requests
    # - $server_root
    # - $server_tokens
    # - $server_signature
    # - $trace_enable
    # - $rewrite_lock
    # - $root_directory_secured
    file { "${::apache::conf_dir}/${::apache::params::conf_file}":
      ensure  => file,
      content => template($conf_template),
      notify  => Class['Apache::Service'],
      require => [Package['httpd']],
    }

    # preserve back-wards compatibility to the times when default_mods was
    # only a boolean value. Now it can be an array (too)
    if is_array($default_mods) {
      class { '::apache::default_mods':
        all  => false,
        mods => $default_mods,
      }
    } else {
      class { '::apache::default_mods':
        all => $default_mods,
      }
    }
    class { '::apache::default_confd_files':
      all => $default_confd_files,
    }
    if $mpm_module and $mpm_module != 'false' { # lint:ignore:quoted_booleans
      include "::apache::mod::${mpm_module}"
    }

    $default_vhost_ensure = $default_vhost ? {
      true  => 'present',
      false => 'absent'
    }
    $default_ssl_vhost_ensure = $default_ssl_vhost ? {
      true  => 'present',
      false => 'absent'
    }

    ::apache::vhost { 'default':
      ensure          => $default_vhost_ensure,
      port            => '80',
      docroot         => $docroot,
      scriptalias     => $scriptalias,
      serveradmin     => $serveradmin,
      access_log_file => $access_log_file,
      priority        => '15',
      ip              => $ip,
      logroot_mode    => $logroot_mode,
      manage_docroot  => $default_vhost,
    }
    $ssl_access_log_file = $::osfamily ? {
      'freebsd' => $access_log_file,
      default   => "ssl_${access_log_file}",
    }
    ::apache::vhost { 'default-ssl':
      ensure          => $default_ssl_vhost_ensure,
      port            => '443',
      ssl             => true,
      docroot         => $docroot,
      scriptalias     => $scriptalias,
      serveradmin     => $serveradmin,
      access_log_file => $ssl_access_log_file,
      priority        => '15',
      ip              => $ip,
      logroot_mode    => $logroot_mode,
      manage_docroot  => $default_ssl_vhost,
    }
  }

  # This anchor can be used as a reference point for things that need to happen *after*
  # all modules have been put in place.
  anchor { '::apache::modules_set_up': }
}
