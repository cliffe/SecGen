class php::install {

  Exec { path => ['/bin', '/usr/bin', '/usr/local/bin', '/sbin', '/usr/sbin'] }

  # lsb-release is not in the bookworm base image; the sources line below needs `lsb_release -sc`
  # (and wget for the key). Without them php.list is written with an empty suite and apt-get update fails.
  ensure_packages(['ca-certificates', 'apt-transport-https', 'lsb-release', 'wget'], { ensure => 'latest'})

  exec { 'install php5 gpg key':
    command => '/usr/bin/wget --no-check-certificate -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg',
    creates => '/etc/apt/trusted.gpg.d/php.gpg',
    require => Package['ca-certificates', 'wget'],
  } ->

  exec { 'add repo to sources':
    command =>
      "/bin/echo \"deb ${secgen_functions::mirror_url('https://packages.sury.org/php/')} \$(lsb_release -sc) main\" > /etc/apt/sources.list.d/php.list",
    creates => '/etc/apt/sources.list.d/php.list',
    require => Package['lsb-release'],
  } ->

  exec { 'apt update':
    command => '/usr/bin/apt-get update',
  } ->

  package { ['php5.6', 'php5.6-mysql','php5.6-cli', 'php5.6-common', 'php5.6-curl', 'php5.6-mbstring','php5.6-xml']:
    ensure => installed,
  } ->

  package { 'php7.0-common':
    ensure => 'absent',
  }
  # ->
  #
  # exec { 'disable php7':
  #   command => '/usr/sbin/a2dismod php7.0',
  #   require => [Exec['install php5 gpg key'], Exec['add repo to sources']],
  # }
}
