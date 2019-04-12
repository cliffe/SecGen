# auditbeat::install
# @api private
#
# @summary It installs the auditbeat package
class auditbeat::install {
  case $auditbeat::ensure {
    'present': {
      $package_ensure = $auditbeat::package_ensure
    }
    default: {
      $package_ensure = $auditbeat::ensure
    }
  }
  package{'auditbeat':
    ensure => $package_ensure,
  }
}
