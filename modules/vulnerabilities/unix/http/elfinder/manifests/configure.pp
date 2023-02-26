class elfinder::configure {
	#secgen parameters commented out and hardcode inputs used for testing
	##$secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
	$leaked_filenames = ["flagtest"] ##$secgen_parameters['leaked_filenames']
	$strings_to_leak = ["this is a list of strings that are secrets / flags","another secret"] ##$secgen_parameters['strings_to_leak']
	$releasename = 'elFinder-2.1.58'
	$docroot = "/var/www/$releasename"
	$dir_array=['folder1', 'folder2', 'folder3'] ##$secgen_parameters['strings_to_pre_leak'], 

	 Exec { path => ['/bin', '/usr/bin', '/usr/local/bin', '/sbin', '/usr/sbin'] }
	 
	#create public directory
	file { "${docroot}/files/public":
		ensure  => directory,
		mode   => '0777',
    }
	
	#add read only folders 
	$dir_array.each |String $dir_array| {
	  file { "${docroot}/files/${leaked_filenames}":
		ensure => directory,
		owner  => 'www-data',
		mode   => '0444',
	  }
	}
	
	#create flag directory
	file { "${docroot}/files/.hidden":
		ensure  => directory,
		owner  => 'www-data',
		mode   => '0700',
		  
    }
	#FOR TESTING ONLY
	file { "${docroot}/files/.hidden/${leaked_filenames}":
		ensure  => present,
		owner  => 'www-data',
		mode   => '0700',
		  
    }
	
	# ::secgen_functions::leak_files { 'elfinder-flag-leak':
		# storage_directory => '$docroot/files/.hidden',
		# leaked_filenames  => $leaked_filenames,
		# strings_to_leak   => $strings_to_leak,
		# owner             => 'www-data',
		# mode              => '0750',
		# leaked_from       => 'elfinder',
	#}
	

}