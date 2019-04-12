# = Class: firewall::linux::gentoo
#
# Manages `iptables` and `ip6tables` services, and creates files used for
# persistence, on Gentoo Linux systems.
#
# == Parameters:
#
# [*ensure*]
#   Ensure parameter passed onto Service[] resources.
#   Default: running
#
# [*enable*]
#   Enable parameter passed onto Service[] resources.
#   Default: true
#
class firewall::linux::gentoo (
  $ensure         = 'running',
  $enable         = true,
  $service_name   = $::firewall::params::service_name,
  $package_name   = $::firewall::params::package_name,
  $package_ensure = $::firewall::params::package_ensure,
) inherits ::firewall::params {
  if $package_name {
    package { $package_name:
      ensure => $package_ensure,
    }
  }

  service { $service_name:
    ensure    => $ensure,
    enable    => $enable,
    hasstatus => true,
  }

  file { '/var/lib/iptables/rules-save':
    ensure => present,
    before => Service[$service_name],
  }

  file { '/var/lib/iptables/rules-save6':
    ensure => present,
    before => Service[$service_name],
  }
}
