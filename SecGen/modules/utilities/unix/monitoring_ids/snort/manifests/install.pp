class snort::install {

  # install rules and config via debian repo
  package { ['snort-rules-default','snort-common']:
    ensure => installed,
  } ->

  # force it to not be enabled because the interface in the config may be wrong
  exec { 'install snort':
    path     => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ],
    command  => '/bin/true',
    provider => shell,
    onlyif   => 'apt-get install -y snort; systemctl disable snort',
  }
}
