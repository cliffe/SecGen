# == Class: cron::install
#
# This class ensures that the distro-appropriate cron package is installed
#
# This class should not be used directly under normal circumstances
# Instead, use the *cron* class.
#
class cron::install {
  if $::cron::manage_package {
    package { 'cron':
      ensure => $::cron::package_ensure,
      name   => $::cron::package_name,
    }
  }
}
