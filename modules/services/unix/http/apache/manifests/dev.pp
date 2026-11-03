class apache::dev {

  if ! defined(Class['apache']) {
    fail('You must include the apache base class before using any apache defined resources')
  }

  $packages = $::apache::dev_packages
  if $packages { # FreeBSD doesn't have dev packages to install
    package { $packages:
      ensure  => present,
      require => Package['httpd'],
    }
  }
}
