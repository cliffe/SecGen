class apache_couchdb::couchdb {
	#$secgen_parameters=secgen_functions::get_parameters($::base64_inputs_file)
	#$account = parsejson($secgen_params['account'][0])
	$username = 'couchdb' ##TODO secgen
	$password = 'password' ##TODO secgen
	$host ='127.0.0.1'
	$docroot = '/opt/couchdb'
	$database_dir = '/var/lib/couchdb'
	$uid = fqdn_uuid('localhost.com')
	$port =  '34023'
	
	
	Exec { path => ['/bin', '/usr/bin', '/usr/local/bin', '/sbin', '/usr/sbin'] }
	#create user
	#create system user
	::accounts::user { "${username}":
		shell      => '/bin/bash',
		ensure => present,
		password   => pw_hash($password, 'SHA-512', 'mysalt'),
	}->
	#set folder permissions
	exec { 'chown-couchdb':
		command => "chown -R ${username}:${username} ${docroot}",
		logoutput => true
	}->
	exec { 'chmod-couchdb':
		command => "chmod -R 770 ${docroot}",
		logoutput => true
	}->
	
	
	#configuration file
	file { "${docroot}/etc/local.ini" :
		 ensure => file,
		 content => template("apache_couchdb/local.ini.erb"),
	}->
	# add vm.args files
	file { "${docroot}/etc/vm.args":
		ensure => file,
		content => template("apache_couchdb/vm.args.erb"),
		notify => Exec['restart-couchdb']
	
	}
	
	#restart couch db
	exec {'restart-couchdb':
		command => 'systemctl restart couchdb',
		logoutput => true,
		notify => Exec['wait-apache-couchdb']
	}
	exec { 'wait-apache-couchdb':
		command => 'sleep 4',
		logoutput => true,
		notify => Exec['chown-uri-file'],
	}
	exec { 'chown-uri-file':
		command => "chown -R ${username}:${username} /var/run/couchdb/",
		logoutput => true,
	}->
	exec { 'chmod-uri-file':
		command => "chmod -R 770 /var/run/couchdb/",
		logoutput => true,
	}
	
	

}