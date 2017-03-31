class onlinestore::install {
  $json_inputs = base64('decode', $::base64_inputs)
  $secgen_parameters = parsejson($json_inputs)

  # Parse out parameters
  $db_flag = $secgen_parameters['db_flag'][0]
  $file_flag = $secgen_parameters['file_flag'][0]
  $root_file_flag = $secgen_parameters['root_file_flag'][0]

  $docroot = '/var/www'
  $db_username = 'csecvm'
  $db_password = 'H93AtG6akq'

  package { ['mysql-client','php5-mysql']:
    ensure => 'installed',
  }

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
    command => "sudo ./mysql_setup.sh $db_username $db_password $db_flag",
    path    => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ],
    notify => Exec['create_flag1'],
  }

  exec { 'create_flag1':
    cwd     => "/home/vagrant",
    command => "echo '$file_flag' > /flag.txt && chown -f root:root /flag.txt && chmod -f 0600 /flag.txt",
    path    => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ],
  }
}