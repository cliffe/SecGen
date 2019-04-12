# to manage filebeat installation on OpenBSD
class filebeat::install::openbsd {
  package {'filebeat':
    ensure => $filebeat::package_ensure,
  }
}
