# filebeat::install
#
# A private class to manage the installation of Filebeat
#
# @summary A private class that manages the install of Filebeat
class filebeat::install {
  anchor { 'filebeat::install::begin': }

  case $::kernel {
    'Linux':   {
      class{ '::filebeat::install::linux':
        notify => Class['filebeat::service'],
      }
      Anchor['filebeat::install::begin'] -> Class['filebeat::install::linux'] -> Anchor['filebeat::install::end']
      if $::filebeat::manage_repo {
        class { '::filebeat::repo': }
        Class['filebeat::repo'] -> Class['filebeat::install::linux']
      }
    }
    'FreeBSD': {
      class{ '::filebeat::install::freebsd':
        notify => Class['filebeat::service'],
      }
      Anchor['filebeat::install::begin'] -> Class['filebeat::install::freebsd'] -> Anchor['filebeat::install::end']
    }
    'OpenBSD': {
      class{'filebeat::install::openbsd':}
      Anchor['filebeat::install::begin'] -> Class['filebeat::install::openbsd'] -> Anchor['filebeat::install::end']
    }
    'Windows': {
      class{'::filebeat::install::windows':
        notify => Class['filebeat::service'],
      }
      Anchor['filebeat::install::begin'] -> Class['filebeat::install::windows'] -> Anchor['filebeat::install::end']
    }
    default:   {
      fail($filebeat::kernel_fail_message)
    }
  }

  anchor { 'filebeat::install::end': }

}
