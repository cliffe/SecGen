class codoforum_rce_authenticated::configure {
	#secgen parameters commented out and hardcode inputs used for testing
	##$secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
	$leaked_filenames = ["flagtest"] ##$secgen_parameters['leaked_filenames']
	$strings_to_leak = ["this is a list of strings that are secrets / flags","another secret"] ##$secgen_parameters['strings_to_leak']
	$strings_to_pre_leak =  ["The username is admin", "The password is password"] ##$secgen_parameters['strings_to_pre_leak']
	$web_pre_leak_filename = "TODO" ##$secgen_parameters['web_pre_leak_filename'][0]  

	# sets the default paths to use
	Exec { path => ['/bin', '/usr/bin', '/usr/local/bin', '/sbin', '/usr/sbin'] }
  	#remove install folder
	file{ 'remove-codoforum-install':
		path => '/var/www/html/codoforum/install',
		ensure => absent,
		recurse => true,
		force   => true
    }

#   ::secgen_functions::leak_files { 'codoforum-flag-leak':
#     	storage_directory => '/var/www/html/codoforum/cf-content/tmp',
#     	leaked_filenames  => $leaked_filenames,
#     	strings_to_leak   => $strings_to_leak,
#     	owner             => 'www-data',
#     	mode              => '0750',
#     	leaked_from       => 'codoforum_rce_authenticated',
#   }


}