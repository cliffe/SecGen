class librenms_rce::webserver{
	$timezone ='Europe/London'
	$port = '80'
	$host = 'localhost'
	$username = 'librenms' ##TODO $secgen_parameters
	$password = 'password' ##TODO $secgen_parameters
	#$nginx_server_name = www.librenms_example.com ##SECGEN parameter
	$community_string = fqdn_rand_string(20, 'ABCDEF!@$%^') ##secgen? 
	#TODO FIX NGIX server (virtual host or permissions issues)
	Exec { path => ['/bin', '/usr/bin', '/usr/local/bin', '/sbin', '/usr/sbin'] }
	#Configure and Start PHP-FPM
	#set time zones
	exec{'set-system-timezone':
		command => "timedatectl set-timezone ${timezone}",
        logoutput => true, 
	}->
	file_line{ 'set-timezone-fpm':
		ensure => present,
		path   => '/etc/php/7.3/fpm/php.ini',
		line   => "date.timezone =${timezone}",
		match  => '^date.timezone =',
	} ->
	file_line{ 'set-timezone-cli':
		ensure => present,
		path   => '/etc/php/7.3/cli/php.ini',
		line   => "date.timezone =${timezone}",
		match  => '^date.timezone =',
	}->
	exec{'restart-php-fpm':
		command => 'service php7.3-fpm restart',
        logoutput => true, 
	
	}
	#configure nginx
	
	file{'nginx-deafult':
		ensure => absent,
		path   => '/etc/nginx/sites-enabled/default',
		
	
	}->
	file { 'librenms.conf':
		ensure  => present,
		path => '/etc/nginx/sites-available/librenms.vhost',
		content  => template('librenms_rce/librenms.vhost.erb'),
    }->
	exec {'restart-nginx':
		command => 'systemctl restart nginx',
        logoutput => true,
		require => Exec['restart-php-fpm'],		
	}
	#configure snmpd
	exec { 'copy-config-snmp':
		command => 'cp /opt/librenms/snmpd.conf.example /etc/snmp/snmpd.conf',
        logoutput => true,
		require => Exec['restart-nginx'],
	} ->
	#update permissions
	exec { 'chmod-snmpd.conf':
		command => 'chmod 660 /etc/snmp/snmpd.conf',
		logoutput => true,
	}->
	#edit community string in snmpd.conf file
	file_line{ 'snmp-community_string':
		ensure => present,
		path   => '/etc/snmp/snmpd.conf',
		line   => "com2sec readonly  default $community_string",
		match  => '^com2sec readonly  default',
	}->
	file { 'distro':
		ensure  => present,
		path => '/usr/bin/distro',
		source  => 'puppet:///modules/librenms_rce/distro.txt',
	}->
	exec{ 'chmod-distro':
		cwd => '/usr/bin/',
		command => 'chmod +x /usr/bin/distro',
        logoutput => true,
	}->
	exec {'restart-snmp':
		command => 'service snmpd restart',
        logoutput => true, 
	}
	
	#cron job
	#TODO set up proxy variables after install
	exec { 'copy-cron':
		command => 'cp /opt/librenms/librenms.nonroot.cron /etc/cron.d/librenms',
        logoutput => true,
	} 
		
	#Iogrotate configuration
	exec { 'copy-log':
		command => 'cp /opt/librenms/misc/librenms.logrotate /etc/logrotate.d/librenms',
        logoutput => true,
	} 
	
	




}