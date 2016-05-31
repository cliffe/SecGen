class apache::dev {
  include ::apache::params
  $packages = $::apache::dev_packages
  if $packages { # FreeBSD doesn't have dev packages to install
    package { $packages:
      ensure  => present,
      require => Package['httpd'],
    }
  }
}
