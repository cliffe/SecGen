class pandora_fms_rce::lamp{
	$db_password = 'db_password' ##$secgen_parameters['db_password'][0]
	$db_admin = 'db_admin' ##$secgen_parameters['db_admin'][0]
	$db_name = 'pandora'##$secgen_parameters['db_name'][0]
	$homedir = '/var/www/html/pandora_console'
	$homeurl= '/pandora_console'
	$auth= 'mysql'
	$host = 'localhost'
	$port = '80'
	$docroot = '/var/www/html/pandorafms' 

	
	# sets the default paths to use
	Exec { path => ['/bin', '/usr/bin', '/usr/local/bin', '/sbin', '/usr/sbin'] }
	
	

	#set up mysql database
	mysql::db { 'pandora_database':
		user     => $db_admin,
		password => $db_password,
		dbname   => $db_name,
		host     => $host,
		grant    =>  ['ALL'],
		sql => ['/var/www/html/pandorafms/pandora_console/pandoradb.sql'],
	}->
	#ensure db admin is a privledged user 
	mysql_grant { "${db_admin}@${host}/*.*":
	  user       => "${db_admin}@${host}",
	  table      => '*.*',
	  privileges => ['ALL'],
	}->
	exec { 'mysqldmin flush-privileges':
		command => 'mysqldmin flush-privileges',
		logoutput => true
	}

	file_line{ 'my.cnf_mysqld':
		ensure => present,
		path   => '/etc/mysql/my.cnf',
		line   => '[mysqld]',
		match  => '^\[mysqld\]',
	}->
	file_line{ 'my.cnf_sql_mode':
		ensure => present,
		path   => '/etc/mysql/my.cnf',
		line   => 'sql_mode=NO_ENGINE_SUBSTITUTION',
		after  => '\[mysqld\]',
	}->
	##TODO confirm charset uploading correctly
	exec { 'populate-database':
		command => "mysql ${db_name} < ${docroot}/pandora_console/pandoradb_data.sql",
		logoutput => true, 
	
	}->
	exec { 'start-database': 
		command => 'systemctl restart mariadb',
		logoutput => true,  
	}	
	
	file{ 'console-install':
		path => "${docroot}/pandora_console/install.php",
		ensure => absent,
    }
	
	class { '::apache':
		default_vhost => false,
		default_mods => ['rewrite'],
		overwrite_ports => false,
		mpm_module => 'prefork'	
	} 
	#pandora configuration file
	file { 'console-config.inc.php':
		path => "${docroot}/pandora_console/include/config.inc.php",
		ensure  => present,
		content  => template('pandora_fms_rce/config.inc.php.erb'),
    }
	
	#update folder permissions 
	exec { 'chown-pandora':
		command => "chown www-data:www-data ${docroot} -R", 
	}->
	exec { 'chown-pandora-console':
		command => "chown www-data:www-data ${docroot}/pandora_console -R",
	}->
	exec { 'chown-pandora-permissions':
		command => "chown 775 ${docroot}/pandora_console -R",
	}

	::apache::vhost { 'www-pandora':
		port    => $port,
		docroot => "${docroot}/pandora_console",
	} 
	file{ 'remove-default-index':
		path => '/var/www/html/index.html',
		ensure => absent,
		require => Class['::apache']
    }
	file{ 'remove-apache2-default-page-enabled':
		path => '/etc/apache2/sites-enabled/000-default.conf',
		ensure => absent,
		require => Class['::apache']
    }
	
	file{ 'remove-apache2-default-page-available':
		path => '/etc/apache2/sites-available/000-default.conf',
		ensure => absent,
		require => Class['::apache']
    }
	
	exec { 'restart-apache-pandora':
		command => 'systemctl restart apache2',
		logoutput => true,
		require => [File['remove-default-index'],File['remove-apache2-default-page-enabled'],File['remove-apache2-default-page-available']],
	} ->
	exec { 'wait-apache-pandora':
		command => 'sleep 4',
		logoutput => true
	}
		
	
	file_line{ 'php.ini-memory_limit':
		ensure => present,
		path   => '/etc/php/7.3/apache2/php.ini',
		line   => 'memory_limit = 256M',
		match  => '^memory_limit =',
	}->
	file_line{ 'php.ini-upload_max_filesize':
		ensure => present,
		path   => '/etc/php/7.3/apache2/php.ini',
		line   => 'upload_max_filesize = 100M',
		match  => '^upload_max_filesize =',
	}->
	file_line{ 'php.ini-execution_time':
		ensure => present,
		path   => '/etc/php/7.3/apache2/php.ini',
		line   => 'max_execution_time = 360',
		match  => '^max_execution_time =',
	}->
	file_line{ 'php.ini-max_input_vars':
		ensure => present,
		path   => '/etc/php/7.3/apache2/php.ini',
		line   => 'max_input_vars = 2000',
		match  => '^max_input_vars =',
	}->
	file_line{ 'php.ini-date.timezone':
		ensure => present,
		path   => '/etc/php/7.3/apache2/php.ini',
		line   => 'date.timezone = Europe/Paris',
		match  => '^date.timezone =',
	}
	
   
}