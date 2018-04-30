class onlinestore::install {
  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)

  # Parse out parameters
  $db_flag = $secgen_parameters['strings_to_leak'][0]
  $admin_flag = $secgen_parameters['strings_to_leak'][1]
  $root_file_flag = $secgen_parameters['strings_to_leak'][2]
  $black_market_flag = $secgen_parameters['strings_to_leak'][3]
  $admin_token_flag = $secgen_parameters['strings_to_leak'][4]
  $accounts = $secgen_parameters['accounts']
  $domain = $secgen_parameters['domain'][0]
  $dealer_id = $secgen_parameters['dealer_id'][0]
  $murderer_id = $secgen_parameters['murderer_id'][0]
  $murdered_on = $secgen_parameters['murdered_on']
  $murdered_ids = $secgen_parameters['murdered_ids']
  $db_password = $secgen_parameters['db_password'][0]

  $docroot = '/var/www/onlinestore'
  $db_username = 'csecvm'

  Exec { path => ['/bin', '/usr/bin', '/usr/local/bin', '/sbin', '/usr/sbin'], }

  file { "$docroot/index.html":
    ensure => absent,
    notify => File[$docroot],
  }

  # Copy www-data to server
  file { $docroot:
    ensure => directory,
    recurse => true,
    mode   => '0600',
    owner => 'www-data',
    group => 'www-data',
    source => 'puppet:///modules/onlinestore/www-data',
    notify => File["$docroot/mysql.php"],
  }

  # Apply templates
  file { "$docroot/mysql.php":
    mode   => '0600',
    owner => 'www-data',
    group => 'www-data',
    content => template('onlinestore/mysql.php.erb'),
    notify => File["$docroot/signup.php"],
  }

  file { "$docroot/signup.php":
    mode   => '0600',
    owner => 'www-data',
    group => 'www-data',
    content => template('onlinestore/signup.php.erb'),
    notify => File["$docroot/u/settings.php"],
  }

  file { "$docroot/u/settings.php":
    mode   => '0600',
    owner => 'www-data',
    group => 'www-data',
    content => template('onlinestore/settings.php.erb'),
    notify => File["/tmp/csecvm.sql"],
  }

  # Database Setup
  file { "/tmp/csecvm.sql":
    owner  => root,
    group  => root,
    mode   => '0600',
    ensure => file,
    content => template('onlinestore/csecvm.sql.erb'),
    notify => File["/tmp/mysql_setup.sh"],
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
    notify => Exec['create_root_flag'],
  }

  # Add flags
  exec { 'create_root_flag':
    cwd     => "/home/vagrant",
    command => "echo '$root_file_flag' > /webroot && chown -f root:root /webroot && chmod -f 0600 /webroot",
    notify => Exec['create_admin_flag'],
  }

  exec { 'create_admin_flag':
    cwd     => "$docroot",
    command => "echo '$admin_flag' > ./.admin && chown -f www-data:www-data ./.admin && chmod -f 0600 ./.admin",
    notify => Exec['create_black_market_flag'],
  }

  exec { 'create_black_market_flag':
    cwd     => "$docroot",
    command => "echo '$black_market_flag' > ./.marketToken && chown -f www-data:www-data ./.marketToken && chmod -f 0600 ./.marketToken",
    notify => Exec['create_admin_token_flag'],
  }

  exec { 'create_admin_token_flag':
    cwd     => "$docroot/admin/",
    command => "echo '$admin_token_flag' > ./.adminToken && chown -f www-data:www-data ./.adminToken && chmod -f 0600 ./.adminToken",
  }
}