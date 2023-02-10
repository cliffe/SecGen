class elfinder::apache{
	#install web server
	#secgen parameters commented out and hardcode inputs used for testing
	##$secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
	$port = '80' ##$secgen_parameters['port'][0]
	$releasename = 'elFinder-2.1.58'
	$docroot = "/var/www/$releasename"
	
	Exec { path => ['/bin', '/usr/bin', '/usr/local/bin', '/sbin', '/usr/sbin'] }
	
	class { '::apache':
		default_vhost => false,
		default_mods => ['rewrite'],
		overwrite_ports => false,
		mpm_module => 'prefork'
	} ->
	#unzip install and update permissions 
	exec {'elfinder':
		cwd => '/usr/local/src',
		command => "unzip $releasename.zip -d /var/www/",
		creates => "$docroot"
	}->
	exec { 'chown-elfinder':
		command => "chown www-data. /var/www/ -R",
	}->exec { 'chown-elfinder-permissions':
		command => "chown 755 /var/www/ -R",
	}->
	::apache::vhost { 'www-elfinder':
		port    => $port,
		docroot => $docroot,
	}->
	#remove default apache files
	file{ '/var/www/html/index.html':
        ensure  => absent,
    } ->
	file{ '/etc/apache2/sites-enabled/000-default.conf':
	    ensure  => absent,
	}-> 
	file { "$docroot/php/connector.minimal.php":
		ensure  => present,
		content  => template('elfinder/connector.minimal.php')
    }->
	#removed url for 3rd party source and added custom congfigurations 
    file { "$docroot/elfinder.html":
		ensure  => present,
		content  => template('elfinder/elfinder.html')
    }->
	#removed url for 3rd party source
    file { "$docroot/main.js":
		ensure  => present,
		content  => template('elfinder/main.js')
    }->
	#remove links for 3rd party urls
	file { "$docroot/js/elFinder.options.js":
		ensure  => present,
		content  => template('elfinder/elFinder.options.js')
    }->
	file { "$docroot/css/jquery-ui.css":
		ensure  => present,
		content  => template('elfinder/jquery-ui.css')
    }->
	file { "$docroot/js/jquery-ui.min.js":
		ensure  => present,
		content  => template('elfinder/jquery-ui.min.js')
    }->
	file { "$docroot/js/jquery.min.js":
		ensure  => present,
		content  => template('elfinder/jquery.min.js')
    }->
		file { "$docroot/js/require.js":
		ensure  => present,
		content  => template('elfinder/require.js')
    }->
	file { "$docroot/js/require.min.js":
		ensure  => present,
		content  => template('elfinder/require.min.js')
    }->
		file { "$docroot/js/encoding.min.js":
		ensure  => present,
		content  => template('elfinder/encoding.min.js')
    }->

	exec { 'restart-apache-elfinder':
		command => 'systemctl restart apache2',
		logoutput => true
	} ->
	exec { 'wait-apache-elfinder':
		command => 'sleep 4',
	}
	
	
}