# Install PEAR package manager
#
# === Parameters
#
# [*ensure*]
#   The package ensure of PHP pear to install and run pear auto_discover
#
# [*package*]
#   The package name for PHP pear
#
class php::pear (
  $ensure  = $::php::pear_ensure,
  $package = undef,
) inherits ::php::params {

  if $caller_module_name != $module_name {
    warning('php::pear is private')
  }

  # Defaults for the pear package name
  if $package == undef {
    if $::osfamily == 'Debian' {
      # Debian is a litte stupid: The pear package is called 'php-pear'
      # even though others are called 'php5-fpm' or 'php5-dev'
      $package_name = "php-${::php::params::pear_package_suffix}"
    } elsif $::operatingsystem == 'Amazon' {
      # On Amazon Linux the package name is also just 'php-pear'.
      # This would normally not be problematic but if you specify a
      # package_prefix other than 'php' then it will fail.
      $package_name = "php-${::php::params::pear_package_suffix}"
    } elsif $::osfamily == 'FreeBSD' {
      # On FreeBSD the package name is just 'pear'.
      $package_name = $::php::params::pear_package_suffix
    } else {
      # This is the default for all other architectures
      $package_name =
        "${::php::package_prefix}${::php::params::pear_package_suffix}"
    }
  } else {
    $package_name = $package
  }

  validate_string($ensure)
  validate_string($package_name)

  if $::operatingsystem == 'Ubuntu' {
    ensure_packages(["${php::package_prefix}xml"], {
      ensure  => present,
      require => Class['::apt::update'],
    })

    package { $package_name:
      ensure  => $ensure,
      require => [Class['::apt::update'],Class['::php::cli'],Package["${php::package_prefix}xml"]],
    }
  } else {
    package { $package_name:
      ensure  => $ensure,
      require => Class['::php::cli'],
    }
  }
}
