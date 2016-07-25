class moinmoin_195::install {

  # Install dependencies
  package { ['apache2' ,'libapache2-mod-wsgi']:
    ensure => installed,
  }

  # Require tarball
  file { '/usr/local/src/MoinMoin-1.9.5.tar.gz':
    ensure => file,
    source => 'puppet:///modules/moinmoin_195/MoinMoin-1.9.5.tar.gz',
  }

  # Unpack tar
  exec { 'unzip-moinmoin':
    command     => '/bin/tar -xzf /usr/local/src/MoinMoin-1.9.5.tar.gz',
    cwd         => '/usr/local/src',
    creates     => '/usr/local/src/moin-1.9.5/',
  }

  # Install moinmoin
  exec { 'install-moinmoin':
    command => '/usr/bin/python setup.py install --force --prefix=/usr/local --record=install.log',
    cwd => '/usr/local/src/moin-1.9.5',
  }
}