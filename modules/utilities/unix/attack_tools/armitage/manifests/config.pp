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
    # msfdb reinit migrates Metasploit's whole schema; Puppet's default 300 s ran out on a busy host.
    timeout => 1800,
  }

  # msfdb (or the Kali image) can leave postgresql disabled, so it is not running after the post-build
  # reboot and the msf database is unreachable. Enable it again once the database is initialised.
  exec { 'enable postgresql at boot':
    path     => ['/usr/bin', '/usr/sbin', '/bin', '/sbin'],
    command  => 'systemctl enable postgresql',
    unless   => 'systemctl is-enabled postgresql',
    provider => shell,
    require  => Exec['msfdb reinit'],
  }
}
