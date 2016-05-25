class lamp::config {
  # Apache2 files
  file { '/etc/apache2/apache2.conf':
    require => Package['apache2'],
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content  => template('lamp/apache2/apache2.erb')
  }
  file { '/etc/apache2/ports.conf':
    require => Package['apache2'],
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content  => template('lamp/apache2/ports.erb')
  }
  file {'/etc/apache2/sites-enabled/default':
    require => Package['apache2'],
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content  => template('lamp/apache2/sites-enabled/default.erb')
  }
  file {'/etc/apache2/sites-enabled/default-ssl':
    require => Package['apache2'],
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content  => template('lamp/apache2/sites-enabled/default-ssl.erb')
  }

  # Mysql files
  file {'/etc/mysql/my.cnf':
    require => Package['apache2'],
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content  => template('lamp/mysql/my.cnf.erb')
  }

  # Php files
  file {'/etc/php5/apache2/php.ini':
    require => Package['apache2'],
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content  => template('lamp/php5/apache2/php.ini.erb')
  }
  file {'/etc/php5/cli/php.ini':
    require => Package['apache2'],
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content  => template('lamp/php5/cli/php.ini.erb')
  }
  file {'/etc/php5/mods-available/pdo.ini':
    require => Package['apache2'],
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content  => template('lamp/php5/mods-available/pdo.ini.erb')
  }
}