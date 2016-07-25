class moinmoin_195::config {

  # Config files
  file { '/usr/local/share/moin/moin.wsgi':
    ensure => file,
    source => 'puppet:///modules/moinmoin_195/moin.wsgi'
  }

  file { '/usr/local/share/moin/wikiconfig.py':
    ensure => file,
    source => '/usr/local/share/moin/config/wikiconfig.py'
  }

  # Web server config
  file { '/etc/apache2/apache2.conf':
    ensure => file,
    source => 'puppet:///modules/moinmoin_195/apache2.conf'
  }

  # File permissions + ownership
  exec { 'permissions-moinmoin':
    command => '/bin/chown -R www-data:www-data /usr/local/share/moin;
    /bin/chmod -R ug+rwx /usr/local/share/moin;
    /bin/chmod -R o-rwx /usr/local/share/moin',
    notify => Service['apache2']
  }
}