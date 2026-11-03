class apache::mod::passenger (
  $passenger_conf_file                                                                   = $::apache::params::passenger_conf_file,
  $passenger_conf_package_file                                                           = $::apache::params::passenger_conf_package_file,
  $passenger_high_performance                                                            = undef,
  $passenger_pool_idle_time                                                              = undef,
  $passenger_max_request_queue_size                                                      = undef,
  $passenger_max_requests                                                                = undef,
  Optional[Enum['smart', 'direct', 'smart-lv2', 'conservative']] $passenger_spawn_method = undef,
  $passenger_stat_throttle_rate                                                          = undef,
  $rack_autodetect                                                                       = undef,
  $rails_autodetect                                                                      = undef,
  $passenger_root                                                                        = $::apache::params::passenger_root,
  $passenger_ruby                                                                        = $::apache::params::passenger_ruby,
  $passenger_default_ruby                                                                = $::apache::params::passenger_default_ruby,
  $passenger_max_pool_size                                                               = undef,
  $passenger_min_instances                                                               = undef,
  $passenger_max_instances_per_app                                                       = undef,
  $passenger_use_global_queue                                                            = undef,
  $passenger_app_env                                                                     = undef,
  Optional[Stdlib::Absolutepath] $passenger_log_file                                     = undef,
  $passenger_log_level                                                                   = undef,
  $passenger_data_buffer_dir                                                             = undef,
  $manage_repo                                                                           = true,
  $mod_package                                                                           = undef,
  $mod_package_ensure                                                                    = undef,
  $mod_lib                                                                               = undef,
  $mod_lib_path                                                                          = undef,
  $mod_id                                                                                = undef,
  $mod_path                                                                              = undef,
) inherits ::apache::params {

  include ::apache

  # Managed by the package, but declare it to avoid purging
  if $passenger_conf_package_file {
    file { 'passenger_package.conf':
      path => "${::apache::confd_dir}/${passenger_conf_package_file}",
    }
  }

  $_package = $mod_package
  $_package_ensure = $mod_package_ensure
  $_lib = $mod_lib
  if $::osfamily == 'FreeBSD' {
    if $mod_lib_path {
      $_lib_path = $mod_lib_path
    } else {
      $_lib_path = "${passenger_root}/buildout/apache2"
    }
  } else {
    $_lib_path = $mod_lib_path
  }

  if $::osfamily == 'RedHat' and $manage_repo {
    if $::operatingsystem == 'Amazon' {
      $baseurl = 'https://oss-binaries.phusionpassenger.com/yum/passenger/el/6Server/$basearch'
    } else {
      $baseurl = 'https://oss-binaries.phusionpassenger.com/yum/passenger/el/$releasever/$basearch'
    }

    yumrepo { 'passenger':
      ensure        => 'present',
      baseurl       => $baseurl,
      descr         => 'passenger',
      enabled       => '1',
      gpgcheck      => '0',
      gpgkey        => 'https://packagecloud.io/gpg.key',
      repo_gpgcheck => '1',
      sslcacert     => '/etc/pki/tls/certs/ca-bundle.crt',
      sslverify     => '1',
      before        => Apache::Mod['passenger'],
    }
  }

  unless ($::operatingsystem == 'SLES') {
    $_id = $mod_id
    $_path = $mod_path
    ::apache::mod { 'passenger':
      package        => $_package,
      package_ensure => $_package_ensure,
      lib            => $_lib,
      lib_path       => $_lib_path,
      id             => $_id,
      path           => $_path,
      loadfile_name  => 'zpassenger.load',
    }
  }

  # Template uses:
  # - $passenger_root
  # - $passenger_ruby
  # - $passenger_default_ruby
  # - $passenger_max_pool_size
  # - $passenger_min_instances
  # - $passenger_max_instances_per_app
  # - $passenger_high_performance
  # - $passenger_max_requests
  # - $passenger_spawn_method
  # - $passenger_stat_throttle_rate
  # - $passenger_use_global_queue
  # - $passenger_log_file
  # - $passenger_log_level
  # - $passenger_app_env
  # - $passenger_data_buffer_dir
  # - $rack_autodetect
  # - $rails_autodetect
  file { 'passenger.conf':
    ensure  => file,
    path    => "${::apache::mod_dir}/${passenger_conf_file}",
    content => template('apache/mod/passenger.conf.erb'),
    require => Exec["mkdir ${::apache::mod_dir}"],
    before  => File[$::apache::mod_dir],
    notify  => Class['apache::service'],
  }
}
