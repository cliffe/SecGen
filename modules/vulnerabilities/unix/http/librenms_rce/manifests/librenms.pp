class librenms_rce::librenms {
	#TODO Make SecGen parameter? 
	$username = 'librenms' ##TODO $secgen_parameters
	$password = 'password' ##TODO $secgen_parameters
	#TODO make same as librenms user?
	$db_name = 'librenms'##$secgen_parameters['db_name'][0]
	$host = 'localhost'
	$charset = 'utf8mb4'
	$collate ='utf8mb4_unicode_ci'
	
	Exec { path => ['/bin', '/usr/bin', '/usr/local/bin', '/sbin', '/usr/sbin'] }
	
	#create system user
	user { $username:
		ensure => present,
		password   => pw_hash($password, 'SHA-512', 'mysalt'),
		groups => 'www-data',
		home => '/opt/librenms',
		managehome => false,
		system => true,
		notify => Exec['chown-librenms'],
		
	}
	
	#set folder permissions
	exec { 'chown-librenms':
		command => "chown -R ${username}:${username} /opt/librenms",
		logoutput => true
	}->
	exec { 'chmod-librenms':
		command => 'chmod 770 /opt/librenms',
		logoutput => true
	}->
	exec { 'deafult-acl-librenms':
		command => 'setfacl -d -m g::rwx /opt/librenms/rrd /opt/librenms/logs /opt/librenms/bootstrap/cache/ /opt/librenms/storage/',
		logoutput => true
	}->
	exec { 'recursive-acl-librenms':
		command => 'setfacl -R -m g::rwx /opt/librenms/rrd /opt/librenms/logs /opt/librenms/bootstrap/cache/ /opt/librenms/storage/',
		logoutput => true
	}->
	#install composer manually 
	file {  'composer':
		ensure => file,
		path  => '/usr/bin/composer',
		source => 'puppet:///modules/librenms_rce/composer.phar',
	} ->
	exec{ 'chmod-composer':
		cwd => '/usr/bin/',
		command => 'chmod +x /usr/bin/composer',
        logoutput => true
	}
	
	
	#set up librenms database
	mysql::db { 'librenms_database':
		user     => $username,
		password => $password,
		dbname   => $db_name,
		charset => $charset,
		collate =>  $collate,
		host     => $host,
		grant    =>  ['ALL']
   }
   file_line{ '50-server.cnf-innodb':
		ensure => present,
		path   => '/etc/mysql/mariadb.conf.d/50-server.cnf',
		line   => 'innodb_file_per_table=1',
		match  => '^innodb_file_per_table=',
		after => '# * InnoDB'
		
   }
   
   file_line{ '50-server.cnf-lowercase':
		ensure => present,
		path   => '/etc/mysql/mariadb.conf.d/50-server.cnf',
		line   => 'lower_case_table_names=0',
		match  => '^lower_case_table_names=',
		after => '#skip-external-locking'
	}
	
	exec{'restart-mysql':
		command => 'service mysql restart',
        logoutput => true, 
		require => [ File_line['50-server.cnf-lowercase'], File_line['50-server.cnf-innodb'] ]
	
	}


}