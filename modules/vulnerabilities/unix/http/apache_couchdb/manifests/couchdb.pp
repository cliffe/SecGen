class apache_couchdb::couchdb {
  $secgen_parameters=secgen_functions::get_parameters($::base64_inputs_file)
  $username = $secgen_parameters['unix_username'][0]
  $password = $secgen_parameters['used_password'][0]
  $host ='127.0.0.1'
  $docroot = '/opt/couchdb'
  $database_dir = '/var/lib/couchdb'
  $uid = fqdn_uuid('localhost.com')
  $port =  $secgen_parameters['port'][0]

  Exec { path => ['/bin', '/usr/bin', '/usr/local/bin', '/sbin', '/usr/sbin'] }
  #create user
  #create system user
  user { $username:
    ensure   => present,
    shell    => '/bin/bash',
    password => pw_hash($password, 'SHA-512', 'mysalt'),
  }
  #set folder permissions
  -> exec { 'chown-couchdb':
    command   => "chown -R ${username}:${username} ${docroot}",
    logoutput => true
  }
  -> exec { 'chmod-couchdb':
    command   => "chmod -R 770 ${docroot}",
    logoutput => true
  }
  #configuration file
  -> file { "${docroot}/etc/local.ini" :
    ensure  => file,
    content => template('apache_couchdb/local.ini.erb'),
  }
  # add vm.args files
  -> file { "${docroot}/etc/vm.args":
    ensure  => file,
    content => template('apache_couchdb/vm.args.erb'),
    notify  => Exec['restart-couchdb'],
  }

  #restart couch db
  exec {'restart-couchdb':
    command   => 'systemctl restart couchdb',
    logoutput => true,
    notify    => Exec['wait-apache-couchdb'],
  }

  exec { 'wait-apache-couchdb':
    command   => 'sleep 4',
    logoutput => true,
    notify    => Exec['chown-uri-file'],
  }

  exec { 'chown-uri-file':
    command   => "chown -R ${username}:${username} /var/run/couchdb/",
    logoutput => true,
  }
  -> exec { 'chmod-uri-file':
    command   => 'chmod -R 770 /var/run/couchdb/',
    logoutput => true,
  }
  -> service { 'epmd-restart':
    name    => 'epmd',
    restart => '',
    flags   => '-port 1337',
  }
}
