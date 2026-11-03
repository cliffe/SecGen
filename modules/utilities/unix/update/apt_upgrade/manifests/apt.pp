class apt_upgrade::apt {

  notice("Running apt-upgrade module...")

  # Exec title is 'apt_upgrade', not 'update': unix_update (required by this module) already declares Exec['update'].
  case $operatingsystem {
    'Debian': {
      # can't upgrade puppet agent mid-provision or it breaks on oVirt.
      exec { 'hold puppet-agent':
        command => '/usr/bin/apt-mark hold puppet-agent'
      }
      exec { 'apt_upgrade':
        command   => "/usr/bin/apt-get -y upgrade",
        tries     => 5,
        try_sleep => 30,
        timeout => 0,
        logoutput   => true,
        require => Exec['hold puppet-agent'],
      }
      Exec <| title == 'update' |> -> Exec['apt_upgrade']
    }
    'Ubuntu': {
      exec { 'apt_upgrade':
        command   => "/usr/bin/apt-get -y upgrade",
        tries     => 5,
        try_sleep => 30,
        timeout => 0,
        logoutput   => true,
      }
      Exec <| title == 'update' |> -> Exec['apt_upgrade']
    }
  }
}
