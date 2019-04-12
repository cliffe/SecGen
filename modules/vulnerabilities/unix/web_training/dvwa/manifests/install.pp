class dvwa::install {
  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)

  $docroot = '/var/www/dvwa'

  # Copy www-data to server
  file { $docroot:
    ensure => directory,
    recurse => true,
    mode   => '0600',
    owner => 'www-data',
    group => 'www-data',
    source => 'puppet:///modules/dvwa/DVWA-master',
  }

}
