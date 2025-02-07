class codoforum_rce_authenticated::mysql{
	#install mysql using module
	#secgen parameters commented out and hardcode inputs used for testing
	$docroot = '/var/www/html/codoforum'
	$db_password = 'db_password' ##$secgen_parameters['db_password'][0]
	$db_admin = 'db_admin' ##$secgen_parameters['db_admin'][0]
	$db_name = 'codoforum'##$secgen_parameters['db_name'][0]
	$db_driver='mysql'
	$db_host= 'localhost' 
	$uid = fqdn_uuid('localhost.com')
	$secret = fqdn_uuid($::fqdn)
	##$secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
	##$secgen_parameters['organisation'][0]
	$raw_org = '{"business_name":"Artisan Bakery","business_motto":"The loaves are in the oven.","business_address":"1080 Headingley Lane, Headingley, Leeds, LS6 1BN","domain":"artisan-bakery.co.uk","office_telephone":"0113 222 1080","office_email":"orders@artisan-bakery.co.uk","industry":"Bakers","manager":{"name":"Maxie Durgan","address":"1080 Headingley Lane, Headingley, Leeds, LS6 1BN","phone_number":"07645 289149","email_address":"maxie@artisan-bakery.co.uk","username":"maxie","password":""},"employees":[{"name":"Matthew Riley","address":"1080 Headingley Lane, Headingley, Leeds, LS6 1BN","phone_number":"07876 518651","email_address":"matt@artisan-bakery.co.uk","username":"matt","password":""},{"name":"Emelie Lowe","address":"1080 Headingley Lane, Headingley, Leeds, LS6 1BN","phone_number":"07560 246931","email_address":"emelie@artisan-bakery.co.uk","username":"emelie","password":""},{"name":"Antonio Durgan","address":"1080 Headingley Lane, Headingley, Leeds, LS6 1BN","phone_number":"07943 250930","email_address":"antonio@artisan-bakery.co.uk","username":"antonio","password":""}],"product_name":"Baked goods","intro_paragraph":["Finest bakery in Headingley since 1900. Baked fresh daily. Bread loaves, teacakes, sweet and savoury treats. We are open from 9 am til 6 pm, every day except for bank holidays."]}'
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
	$website_theme = '2k18'##$secgen_parameters['website_theme'][0]
	$known_username = "known_username" ##$secgen_parameters['known_username'][0]
	$known_password = "known_password" ##$secgen_parameters['known_password'][0]
	$known_email = "known_username@email.com" ##$secgen_parameters['known_email'][0]

	# sets the default paths to use
	Exec { path => ['/bin', '/usr/bin', '/usr/local/bin', '/sbin', '/usr/sbin'] }


	file { '/usr/local/src/codoforum_tables.sql' :
		 ensure => present,
		 content  => template('codoforum_rce_authenticated/codoforum_tables.sql.erb'),
    }->
	mysql::db { 'cf_database':
		user     => $db_admin,
		password => $db_password,
		dbname   => $db_name,
		host     => $db_host,
		grant    =>  ['ALL'],
		sql => ['/usr/local/src/codoforum_tables.sql'],
   }
   #update config file
   file { "${docroot}/sites/default/config.php":
		ensure  => present,
		content  => template('codoforum_rce_authenticated/config.php.erb')
   }
   
  
  

}
