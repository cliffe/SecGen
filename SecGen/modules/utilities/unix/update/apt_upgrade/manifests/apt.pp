class apt_upgrade::apt {
  case $operatingsystem {
    'Debian': {
      exec { 'update':
        command => "/usr/bin/apt-get upgrade",
        tries => 5,
        try_sleep => 30,
      }
    }
    'Ubuntu': {
      exec { 'update':
        command => "/usr/bin/apt-get upgrade",
        tries => 5,
        try_sleep => 30,
      }
    }
  }
}
