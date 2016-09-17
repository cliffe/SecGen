# = Class: firewall::linux::redhat
#
# Manages the `iptables` service on RedHat-alike systems.
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
class firewall::linux::redhat (
  $ensure         = running,
  $enable         = true,
  $service_name   = $::firewall::params::service_name,
  $package_name   = $::firewall::params::package_name,
  $package_ensure = $::firewall::params::package_ensure,
) inherits ::firewall::params {

  # RHEL 7 and later and Fedora 15 and later require the iptables-services
  # package, which provides the /usr/libexec/iptables/iptables.init used by
  # lib/puppet/util/firewall.rb.
  if ($::operatingsystem != 'Amazon')
  and (($::operatingsystem != 'Fedora' and versioncmp($::operatingsystemrelease, '7.0') >= 0)
  or  ($::operatingsystem == 'Fedora' and versioncmp($::operatingsystemrelease, '15') >= 0)) {
    service { 'firewalld':
      ensure => stopped,
      enable => false,
      before => Package[$package_name],
    }
  }

  if $package_name {
    package { $package_name:
      ensure => $package_ensure,
      before => Service[$service_name],
    }
  }

  if ($::operatingsystem != 'Amazon')
  and (($::operatingsystem != 'Fedora' and versioncmp($::operatingsystemrelease, '7.0') >= 0)
  or  ($::operatingsystem == 'Fedora' and versioncmp($::operatingsystemrelease, '15') >= 0)) {
    if $ensure == 'running' {
      exec { '/usr/bin/systemctl daemon-reload':
        require => Package[$package_name],
        before  => Service[$service_name],
        unless  => "/usr/bin/systemctl is-active ${service_name}",
      }
    }
  }

  service { $service_name:
    ensure    => $ensure,
    enable    => $enable,
    hasstatus => true,
    require   => File["/etc/sysconfig/${service_name}"],
  }

  # Redhat 7 selinux user context for /etc/sysconfig/iptables is set to unconfined_u
  case $::selinux {
    #lint:ignore:quoted_booleans
    'true',true: {
      case $::operatingsystemrelease {
        /^(6|7)\..*/: { $seluser = 'unconfined_u' }
        default: { $seluser = 'system_u' }
      }
    }
    #lint:endignore
    default:     { $seluser = undef }
  }

  file { "/etc/sysconfig/${service_name}":
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    seluser => $seluser,
  }
}
