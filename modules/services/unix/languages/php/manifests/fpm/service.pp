# Manage fpm service
#
# === Parameters
#
# [*service_name*]
#   name of the php-fpm service
#
# [*ensure*]
#   'ensure' value for the service
#
# [*enable*]
#   Defines if the service is enabled
#
# [*provider*]
#   Defines if the service provider to use
#
class php::fpm::service(
  $service_name = $::php::params::fpm_service_name,
  $ensure       = $::php::params::fpm_service_ensure,
  $enable       = $::php::params::fpm_service_enable,
  $provider     = undef,
) inherits ::php::params {

  if $caller_module_name != $module_name {
    warning('php::fpm::service is private')
  }

  $reload = "service ${service_name} reload"

  if $::operatingsystem == 'Ubuntu' and $::operatingsystemmajrelease == '12.04' {
    # Precise upstart doesn't support reload signals, so use
    # regular service restart instead
    $restart = undef
  } else {
    $restart = $reload
  }

  service { $service_name:
    ensure     => $ensure,
    enable     => $enable,
    provider   => $provider,
    hasrestart => true,
    restart    => $restart,
    hasstatus  => true,
  }

  ::Php::Extension <| |> ~> Service[$service_name]
}
