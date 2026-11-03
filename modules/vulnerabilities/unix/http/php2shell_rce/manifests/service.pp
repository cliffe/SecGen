# == Class: php2shell_rce::service
# Start lighttpd serving the practice target.
class php2shell_rce::service {
  require php2shell_rce::install

  service { 'lighttpd':
    ensure => running,
    enable => true,
  }
}
