class gitlist_040::install {

  Exec { path => ['/bin', '/usr/bin', '/usr/local/bin', '/sbin', '/usr/sbin'] }

  ensure_packages('git')

  $archive = 'gitlist-0.4.0.tar.gz'

  file { "/usr/local/src/$archive":
    ensure => file,
    source => "puppet:///modules/gitlist_040/$archive",
  }

  exec { 'unpack-gitlist':
    cwd => '/usr/local/src',
    command => "tar -xzf $archive -C /var/www",
  }

  exec { 'copy-ini-file':
    require => Exec['unpack-gitlist'],
    command => 'cp /var/www/gitlist/config.ini-example /var/www/gitlist/config.ini',
  }

  file { '/var/www/gitlist/cache':
    require => Exec['unpack-gitlist'],
    ensure => directory,
    mode => '777',
  }

  case $operatingsystemrelease {
    /^9.*/: { # do 9.x stretch stuff

      file { '/var/www/gitlist/.htaccess':
        require => Exec['unpack-gitlist'],
        ensure  => present,
        content => template('gitlist_040/.htaccess.erb')
      }
    }
  }
}