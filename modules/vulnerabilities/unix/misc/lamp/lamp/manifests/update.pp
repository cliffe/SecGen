class lamp::update{
  case $operatingsystem {
    'Debian': {
      exec { 'update':
        command => "/usr/bin/apt-get update"
      }
    }
    'Ubuntu': {
      exec { 'update':
        command => "/usr/bin/apt-get update"
      }
    }
    'RedHat': {
      exec { 'update':
        command => "yum update"
      }
    }
    'CentOS': {
      exec { 'update':
        command => "su -c 'yum update'"
      }
    }
    'Solaris': {
      exec { 'update':
        command => "pkg update"
      }
    }
  }
}