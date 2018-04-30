class apache::mod::cgi {
  case $::osfamily {
    'FreeBSD': {}
    default: {
      Class['::apache::mod::prefork'] -> Class['::apache::mod::cgi']
    }
  }

  if $::osfamily == 'Suse' {
    ::apache::mod { 'cgi':
      lib_path => '/usr/lib64/apache2-prefork',
    }
  } else {
    ::apache::mod { 'cgi': }
  }

}
