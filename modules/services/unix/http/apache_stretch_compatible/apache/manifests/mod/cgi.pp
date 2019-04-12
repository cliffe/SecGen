class apache::mod::cgi {
  case $::osfamily {
    'FreeBSD': {}
    default: {
      if $::apache::mpm_module =~ /^(itk|peruser|prefork)$/ {
        Class["::apache::mod::${::apache::mpm_module}"] -> Class['::apache::mod::cgi']
      }
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
