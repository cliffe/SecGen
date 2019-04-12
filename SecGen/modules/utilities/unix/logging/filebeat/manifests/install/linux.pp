# filebeat::install::linux
#
# Install the linux filebeat package
#
# @summary A simple class to install the filebeat package
#
class filebeat::install::linux {
  if $::kernel != 'Linux' {
    fail('filebeat::install::linux shouldn\'t run on Windows')
  }

  package {'filebeat':
    ensure => $filebeat::package_ensure,
  }
}
