# == Class: php82_patched::install
#
# Pins the Debian php8.2 core packages to the fixed security build carrying the
# php2shell backport (CVE-2026-109618 / CVE-2026-109619, DLA-4848-1), so a
# requiring module's own php packages resolve to the same version.

class php82_patched::install {

  Exec { path => ['/bin', '/usr/bin', '/usr/local/bin', '/sbin', '/usr/sbin'] }

  # Refresh the apt cache so the newest php8.2 candidate (the security build) is
  # visible, then pin the core packages to it. php8.2 extensions and SAPIs the
  # requiring module installs depend on php8.2-common at the same version, so
  # they are dragged up to the fixed build too.
  exec { 'php82_patched: apt-get update':
    command => '/usr/bin/apt-get update',
  }
  -> package { ['php8.2-common', 'php8.2-cli']:
    ensure => latest,
  }
}
