class commando::install {
		$secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)

		# attack code snippets
		$search = $secgen_parameters['search']
		$sqli_attack = $secgen_parameters['sqli']

		# On/Off switches
		$aa_activation = $secgen_parameters['default_admin_deactivation'][0]
		$ve_activation = $secgen_parameters['verbose_error_deactivation'][0]

		# Strong password and a new username if the default admin is disabled
		$strong_password = $secgen_parameters['strong_password'][0]
		$alternate_username = $secgen_parameters['alternate_username'][0]

		# Strings to leak for some vulnerabilities
		$xss_flag = $secgen_parameters['xss_string_to_leak']
		$default_login_flag = $secgen_parameters['default_admin_string_to_leak'][0]

		# differenitaion in webiste content generation
		$theme = $secgen_parameters['theme'][0]
		$raw_org = $secgen_parameters['organisation'][0]
		if $raw_org and $raw_org != '' {
			$organisation = parsejson($raw_org)
		}

		if $organisation and $organisation != '' {
			$business_name = $organisation['business_name']
			$business_motto = $organisation['business_motto']
			$manager_profile = $organisation['manager']
			$business_address = $organisation['business_address']
			$office_telephone = $organisation['office_telephone']
			$office_email = $organisation['office_email']
			$industry = $organisation['industry']
			$product_name = $organisation['product_name']
			$employees = $organisation['employees']
			$intro_paragraph = $organisation['intro_paragraph']
		}

		# database differenitaion generation
		$php_database = $secgen_parameters['database']
		$user_table_name = $secgen_parameters['user_table_name'][0]

		# admin account
		$raw_admin = $secgen_parameters['admin_account'][0]
		if $raw_admin and $raw_admin != '' {
			$admin_account = parsejson($raw_admin)
		}

		if $admin_account and $admin_account != '' {
			# For if admin account is disabled
			if aa_activation != 'false' {
			$admin_username = $admin_account['username']
			$admin_password = $admin_account['password']
			} else {
			$admin_username = $strong_password
			$admin_password = $alternate_username
			}
			$admin_name = $admin_account['name']
			$admin_address = $admin_account['address'][0]
		}

		# Test user account so user can see how the portal works
		$raw_user = $secgen_parameters['user'][0]
		if $raw_user and $raw_user != '' {
			$user_account = parsejson($raw_user)
		}

		if $user_account and $user_account != '' {
			$user_username = $user_account['username']
			$user_password = $user_account['password']
			$user_name = $user_account['name']
			$user_address = $user_account['address']
			$user_mobile = $user_account['phone_number']
			$user_email = $user_account['email_address']
		}

		# Docroot used to tell puppet where to store commando files so they can be loaded
		# onto apache server
		$docroot = '/var/www/commando'

		# database credentials
		$db_username = 'commando_user'
		$db_password = $secgen_parameters['db_password'][0]

		# Applying templates to files
		# home page
		file{ "$docroot/index.php":
			ensure  => file,
			content => template('commando/home.php.erb'),
		}

		# about/information page
		file{ "$docroot/information.php":
			ensure => file,
			content => template('commando/information.php.erb')
		}

		# login page
		file{ "$docroot/login.php":
			ensure => file,
			content => template('commando/login.php.erb')
		}

		# profile page
		file{ "$docroot/profile.php":
			ensure => file,
			content => template('commando/profile.php.erb')
		}

		# connection file
		file{ "$docroot/connect.php":
			ensure => file,
			content => template('commando/connect.php.erb')
		}

		# Standard files which are not dynamic moving accross to the server
		# Auth file
		if $ve_activation == 'false' {

			# if the verbose error message is switched on (this is default)
			file{ "$docroot/authentication.php":
			ensure => file,
			content => template('commando/authentication.php.erb')
			}

		} elsif $ve_activation == 'true' {

			# if the verbose error message is switched off
			file{ "$docroot/authentication.php":
			ensure => file,
			content => template('commando/authentication_less_vulnerable.php.erb')
			}

		}

		# CSS file/theme moving over to the server
		# Static CSS
		file { "$docroot/css":
	    ensure => directory,
	    recurse => true,
	    source => 'puppet:///modules/commando/css',
	    require => File[$docroot],
	  }

		# Dynamic theme file
		file { "$docroot/css/$theme":
	    ensure => file,
	    source => "puppet:///modules/commando/css_themes/$theme",
	    require => File[$docroot],
	  }

		# Moving the images directory accross to the server
		file { "$docroot/images":
			ensure => directory,
			recurse => true,
			source => 'puppet:///modules/commando/images',
			require => File[$docroot],
		}

		# Database Setup
		# Table setup file, setting the template
		file { "/tmp/store.sql":
			owner  => root,
			group  => root,
			mode   => '0600',
			ensure => file,
			content => template('commando/store.sql.erb'),
			notify => File["/tmp/mysql_setup.sh"],
		}

		# Moving across the shell script which setups the database
		file { "/tmp/mysql_setup.sh":
			owner  => root,
			group  => root,
			mode   => '0700',
			ensure => file,
			source => 'puppet:///modules/commando/mysql_setup.sh',
			notify => Exec['setup_mysql'],
		}

		# Execute the shell script with the specifed username and password
		exec { 'setup_mysql':
			cwd     => "/tmp",
			command => "sudo ./mysql_setup.sh $db_username $db_password",
			path    => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ],
		}
}
