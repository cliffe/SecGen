# Install and configure mod_php for fpm
#
# === Parameters
#
# [*service_enable*]
#   Enable/disable FPM service
#
# [*service_ensure*]
#   Ensure FPM service is either 'running' or 'stopped'
#
# [*service_name*]
#   This is the name of the php-fpm service. It defaults to reasonable OS
#   defaults but can be different in case of using php7.0/other OS/custom fpm service
#
# [*service_provider*]
#   This is the name of the service provider, in case there is a non
#   OS default service provider used to start FPM.
#   Defaults to 'undef', pick system defaults.
#
# [*pools*]
#   Hash of php::fpm::pool resources that will be created. Defaults
#   to a single php::fpm::pool named www with default parameters.
#
# [*log_owner*]
#   The php-fpm log owner
#
# [*log_group*]
#   The group owning php-fpm logs
#
# [*package*]
#   Specify which package to install
#
# [*ensure*]
#   Specify which version of the package to install
#
# [*inifile*]
#   Path to php.ini for fpm
#
# [*settings*]
#   fpm settings hash
#
# [*global_pool_settings*]
#   Hash of defaults params php::fpm::pool resources that will be created.
#   Defaults is empty hash.
#
class php::fpm (
  $ensure               = $::php::ensure,
  $service_ensure       = $::php::params::fpm_service_ensure,
  $service_enable       = $::php::params::fpm_service_enable,
  $service_name         = $::php::params::fpm_service_name,
  $service_provider     = undef,
  $package              = "${::php::package_prefix}${::php::params::fpm_package_suffix}",
  $inifile              = $::php::params::fpm_inifile,
  $settings             = {},
  $global_pool_settings = {},
  $pools                = { 'www' => {} },
  $log_owner            = $::php::params::fpm_user,
  $log_group            = $::php::params::fpm_group,
) inherits ::php::params {

  if $caller_module_name != $module_name {
    warning('php::fpm is private')
  }

  validate_string($ensure)
  validate_string($package)
  validate_absolute_path($inifile)
  validate_hash($settings)
  validate_hash($pools)

  $real_settings = deep_merge($settings, hiera_hash('php::fpm::settings', {}))

  # On FreeBSD fpm is not a separate package, but included in the 'php' package.
  # Implies that the option SET+=FPM was set when building the port.
  $real_package = $::osfamily ? {
    'FreeBSD' => [],
    default   => $package,
  }

  anchor { '::php::fpm::begin': } ->
    package { $real_package:
      ensure  => $ensure,
      require => Class['::php::packages'],
    } ->
    class { '::php::fpm::config':
      inifile   => $inifile,
      settings  => $real_settings,
      log_owner => $log_owner,
      log_group => $log_group,
    } ->
    class { '::php::fpm::service':
      ensure       => $service_ensure,
      enable       => $service_enable,
      service_name => $service_name,
      provider     => $service_provider,
    } ->
  anchor { '::php::fpm::end': }

  $real_global_pool_settings = hiera_hash('php::fpm::global_pool_settings', $global_pool_settings)
  $real_pools = hiera_hash('php::fpm::pools',  $pools)
  create_resources(::php::fpm::pool, $real_pools, $real_global_pool_settings)

  # Create an override to use a reload signal as trusty and utopic's
  # upstart version supports this
  if $::operatingsystem == 'Ubuntu' and ($::operatingsystemmajrelease == '14.04' or $::operatingsystemmajrelease == '14.10') {
    if ($service_enable) {
      $fpm_override = 'reload signal USR2'
    }
    else {
      $fpm_override = "reload signal USR2\nmanual"
    }
    file { "/etc/init/${::php::fpm::service::service_name}.override":
      content => $fpm_override,
      before  => Package[$real_package],
    }
  }
}
