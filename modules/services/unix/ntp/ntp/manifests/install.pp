# @summary
#   This class handles ntp packages.
#
# @api private
#
class ntp::install {
  if $ntp::package_manage {
    package { $ntp::package_name:
      ensure => $ntp::package_ensure,
    }
  }
}
