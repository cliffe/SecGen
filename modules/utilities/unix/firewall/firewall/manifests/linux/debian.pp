# = Class: firewall::linux::debian
#
# Installs the `iptables-persistent` package for Debian-alike systems. This
# allows rules to be stored to file and restored on boot.
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
class firewall::linux::debian (
  $ensure         = running,
  $enable         = true,
  $service_name   = $::firewall::params::service_name,
  $package_name   = $::firewall::params::package_name,
  $package_ensure = $::firewall::params::package_ensure,
) inherits ::firewall::params {

  if $package_name {
    #Fixes hang while installing iptables-persistent on debian 8
    exec {'iptables-persistent-debconf':
        command     => "/bin/echo \"${package_name} ${package_name}/autosave_v4 boolean false\" | /usr/bin/debconf-set-selections && /bin/echo \"${package_name} ${package_name}/autosave_v6 boolean false\" | /usr/bin/debconf-set-selections",
        refreshonly => true
    }
    package { $package_name:
      ensure  => $package_ensure,
      require => Exec['iptables-persistent-debconf']
    }
  }

  if($::operatingsystemrelease =~ /^6\./ and $enable == true and $::iptables_persistent_version
  and versioncmp($::iptables_persistent_version, '0.5.0') < 0) {
    # This fixes a bug in the iptables-persistent LSB headers in 6.x, without it
    # we lose idempotency
    exec { 'iptables-persistent-enable':
      logoutput => on_failure,
      command   => '/usr/sbin/update-rc.d iptables-persistent enable',
      unless    => '/usr/bin/test -f /etc/rcS.d/S*iptables-persistent',
      require   => Package[$package_name],
    }
  } else {
    # This isn't a real service/daemon. The start action loads rules, so just
    # needs to be called on system boot.
    service { $service_name:
      ensure    => undef,
      enable    => $enable,
      hasstatus => true,
      require   => Package[$package_name],
    }
  }
}
