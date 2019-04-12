class dvwa::config {
  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $port = $secgen_parameters['port'][0]
  $db_password = $secgen_parameters['db_password'][0]
  
  $docroot = '/var/www/dvwa'

  file { "$docroot/config/config.inc.php":
    ensure  => present,
    mode   => '0600',
    owner => 'www-data',
    group => 'www-data',
    content  => template('dvwa/config.inc.php.dist.erb')
  }

}