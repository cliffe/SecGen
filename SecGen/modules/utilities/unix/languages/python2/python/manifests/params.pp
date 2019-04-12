# == Class: python::params
#
# The python Module default configuration settings.
#
class python::params {
  $ensure                 = 'present'
  $version                = 'system'
  $pip                    = 'present'
  $dev                    = 'absent'
  $virtualenv             = 'absent'
  $gunicorn               = 'absent'
  $manage_gunicorn        = true
  $provider               = undef
  $valid_versions = $::osfamily ? {
    'RedHat' => ['3','27','33'],
    'Debian' => ['3', '3.3', '2.7'],
    'Suse'   => [],
    'Gentoo' => ['2.7', '3.3', '3.4', '3.5']
  }

  if $::osfamily == 'RedHat' {
    if $::operatingsystem != 'Fedora' {
      $use_epel           = true
    } else {
      $use_epel           = false
    }
  } else {
    $use_epel             = false
  }

  $gunicorn_package_name = $::osfamily ? {
    'RedHat' => 'python-gunicorn',
    default  => 'gunicorn',
  }

  $rhscl_use_public_repository = true

}
