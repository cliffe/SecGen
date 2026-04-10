# Class: raspap_cmd_injection::service
# Start the lighttpd web server service
class raspap_cmd_injection::service {
  require raspap_cmd_injection::config
  Exec { path => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ] }

  service { 'lighttpd':
    ensure  => running,
    enable  => true,
    require => Class['raspap_cmd_injection::config'],
  }
}
