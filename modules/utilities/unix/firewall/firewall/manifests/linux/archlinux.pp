# = Class: firewall::linux::archlinux
#
# Manages `iptables` and `ip6tables` services, and creates files used for
# persistence, on Arch Linux systems.
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
class firewall::linux::archlinux (
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

  file { '/etc/iptables/iptables.rules':
    ensure => present,
    before => Service[$service_name],
  }

  file { '/etc/iptables/ip6tables.rules':
    ensure => present,
    before => Service[$service_name],
  }
}
