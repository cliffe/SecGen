class distcc_exec::install{
  package { 'distcc':
    ensure => installed,
    install_options => ['--allow-unauthenticated'],
  }
  
  # MSF default cmd exploit requires telnet
  ensure_packages('telnet')
}
