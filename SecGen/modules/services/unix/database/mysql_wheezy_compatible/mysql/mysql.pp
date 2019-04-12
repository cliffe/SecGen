stage { 'preinstall':
  before => Stage['main']
}
class apt_get_update {
  exec { '/usr/bin/apt-get -y update': }
}
class { 'apt_get_update':
  stage => preinstall
}

include '::mysql::server'