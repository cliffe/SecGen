class apache::package (
  $ensure     = 'present',
  $mpm_module = $::apache::params::mpm_module,
) inherits ::apache::params {

  # The base class must be included first because it is used by parameter defaults
  if ! defined(Class['apache']) {
    fail('You must include the apache base class before using any apache defined resources')
  }

  case $::osfamily {
    'FreeBSD': {
      case $mpm_module {
        'prefork': {
          $set = 'MPM_PREFORK'
          $unset = 'MPM_WORKER MPM_EVENT'
        }
        'worker': {
          $set = 'MPM_WORKER'
          $unset = 'MPM_PREFORK MPM_EVENT'
        }
        'event': {
          $set = 'MPM_EVENT'
          $unset = 'MPM_PREFORK MPM_WORKER'
        }
        'itk': {
          $set = undef
          $unset = undef
          package { 'www/mod_mpm_itk':
            ensure => installed,
          }
        }
        default: { fail("MPM module ${mpm_module} not supported on FreeBSD") }
      }

      # Configure ports to have apache build options set correctly
      if $set {
        file_line { 'apache SET options in /etc/make.conf':
          ensure => $ensure,
          path   => '/etc/make.conf',
          line   => "apache24_SET_FORCE=${set}",
          match  => '^apache24_SET_FORCE=.*',
          before => Package['httpd'],
        }
        file_line { 'apache UNSET options in /etc/make.conf':
          ensure => $ensure,
          path   => '/etc/make.conf',
          line   => "apache24_UNSET_FORCE=${unset}",
          match  => '^apache24_UNSET_FORCE=.*',
          before => Package['httpd'],
        }
      }
      $apache_package = $::apache::apache_name
    }
    default: {
      $apache_package = $::apache::apache_name
    }
  }

  package { 'httpd':
    ensure => $ensure,
    name   => $apache_package,
    notify => Class['Apache::Service'],
  }
}
