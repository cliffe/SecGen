class php::install {

  ensure_packages('apt-transport-https')

  exec { 'install php5 gpg key':
    command => '/usr/bin/wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg',
  }

  exec { 'add repo to sources':
    command =>
      '/bin/echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list',
  }

  exec { 'apt update':
    command => '/usr/bin/apt-get update',
    require => [Exec['install php5 gpg key'], Exec['add repo to sources']],
    before  => Package['php5.6']
  }

  package { ['php5.6', 'php5.6-mysql','php5.6-cli', 'php5.6-common', 'php5.6-curl', 'php5.6-mbstring','php5.6-xml']:
    ensure => installed,
  }

}