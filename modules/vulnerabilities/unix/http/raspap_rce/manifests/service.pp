# Class: raspap_rce::service
# Start the lighttpd web server service
class raspap_rce::service {
  require raspap_rce::config
  Exec { path => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ] }

  service { 'lighttpd':
    ensure  => running,
    enable  => true,
    require => Class['raspap_rce::config'],
  }
}
