class apache_couchdb::configure {
	#$secgen_parameters=secgen_functions::get_parameters($::base64_inputs_file)
	#$account = parsejson($secgen_params['account'][0])
	$database = 'new_database' ##TODO secgen
	$username = 'couchdb' ##TODO secgen
	$password = 'password' ##TODO secgen
	$jsondb = 'sampledata' ##TODO secgen
	$strings_to_leak = ["this is a list of strings that are secrets / flags","another secret"]##$secgen_parameters['strings_to_leak']
	$leaked_filenames = ["flagtest"]##$secgen_parameters['leaked_filenames']
	
	Exec { path => ['/bin', '/usr/bin', '/usr/local/bin', '/sbin', '/usr/sbin'] }
	
	#create database 
	exec { 'create-database':
		command => "curl -X PUT http://localhost:34023/${database} -u \"${username}:${password}\"",
		logoutput => true
	}->
	exec { 'import_data':
        cwd=> '/usr/bin/',
		command => "curl -d @${jsondb}.json -H \"Content-type: application/json\" -X POST http://127.0.0.1:34023/${database}/_bulk_docs -u \"${username}:${password}\"",
		logoutput => true
	}
	
	# Leak strings in a text file in the users home directory
	  # ::secgen_functions::leak_files { "$username-file-leak":
		# storage_directory => "/home/${username}",
		# leaked_filenames  => $leaked_filenames,
		# strings_to_leak   => $strings_to_leak,
		# owner             => ${username},
		# group             => ${username},
		# mode              => '0600',
		# leaked_from       => "accounts_$username",
	  # }
	

}