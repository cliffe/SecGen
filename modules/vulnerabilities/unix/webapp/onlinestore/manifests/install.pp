class onlinestore::install {
  $json_inputs = base64('decode', $::base64_inputs)
  $secgen_parameters = parsejson($json_inputs)

  # Parse out parameters
  $db_flag = $secgen_parameters['db_flag'][0]
  $file_flag = $secgen_parameters['file_flag'][0]

  $docroot = '/var/www'

  file { "/var/www/index.html":
    ensure => absent,
  }

  file { "/tmp/www-data.tar.gz":
    owner  => root,
    group  => root,
    mode   => '0600',
    ensure => file,
    source => 'puppet:///modules/onlinestore/www-data.tar.gz',
    notify => Exec['unpack'],
  }

  exec { 'unpack':
    cwd     => "$docroot",
    command => "tar -xzf /tmp/www-data.tar.gz && chown -R www-data:www-data $docroot",
    path    => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ],
    notify => Exec['setup_mysql'],
  }

  file { "/tmp/csecvm.sql":
    owner  => root,
    group  => root,
    mode   => '0600',
    ensure => file,
    source => 'puppet:///modules/onlinestore/csecvm.sql',
  }

  file { "/tmp/mysql_setup.sh":
    owner  => root,
    group  => root,
    mode   => '0700',
    ensure => file,
    source => 'puppet:///modules/onlinestore/mysql_setup.sh',
    notify => Exec['setup_mysql'],
  }

  exec { 'setup_mysql':
    cwd     => "/tmp",
    command => "sudo ./mysql_setup.sh csecvm H93AtG6akq",
    path    => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ],
    notify => Exec['create_flag1'],
  }

  exec { 'create_flag1':
    cwd     => "/home/vagrant",
    command => "echo '$db_flag' > flag.txt",
    path    => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ],
  }
}