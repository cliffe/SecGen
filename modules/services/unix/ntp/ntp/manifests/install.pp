#
class ntp::install inherits ntp {

  if $ntp::package_manage {

    package { $ntp::package_name:
      ensure => $ntp::package_ensure,
    }

  }

}
