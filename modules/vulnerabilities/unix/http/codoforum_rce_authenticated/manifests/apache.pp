class codoforum_rce_authenticated::apache {
	#secgen parameters commented out and hardcode inputs used for testing
	##$secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
	$port = '80' ##$secgen_parameters['port'][0]
	$docroot = '/var/www/html/codoforum'
	$releasename = 'codoforum-v-5-1'
	Exec { path => ['/bin', '/usr/bin', '/usr/local/bin', '/sbin', '/usr/sbin'] }


	class { '::apache':
		default_vhost => false,
		default_mods => ['rewrite'],
		overwrite_ports => false,
		mpm_module => 'prefork'	
	} 
	exec { 'codoforum':
		cwd => '/usr/local/src',
		command => "unzip ${releasename}.zip -d $docroot",
		creates => "$docroot",
		notify => Exec['chown-codoforum']
	} 
	exec { 'chown-codoforum':
		command => "chown www-data. /var/www/html -R",
		notify => Exec['chown-codoforum-permissions']
	}
	exec { 'chown-codoforum-permissions':
		command => "chown 755 /var/www/html -R"
	} ->
	::apache::vhost { 'www-codoforum':
		port    => $port,
		docroot => $docroot
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
    
	
	exec { 'restart-apache-codoforum':
		command => 'systemctl restart apache2',
		logoutput => true,
		notify => Exec['wait-apache-codoforum']
	}
	exec { 'wait-apache-codoforum':
		command => 'sleep 4',
		logoutput => true
	}
	

	
	 
  	 
}