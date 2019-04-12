class armitage::config{
  service { 'postgresql':
    enable => true,
    ensure => 'running',
  } ->

  # initialise the msf database, so that armitage can start it msfrpc on command
  exec { 'msfdb reinit':
    path    => ['/usr/bin', '/usr/sbin',],
    logoutput    => true,
    provider => shell,
    tries => 4,
    try_sleep => 5,
  }
}
