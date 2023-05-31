# Class: nanocms
#
#
class nanocms_exec::configure {
  Exec { path => ['/bin', '/usr/bin', '/usr/local/bin', '/sbin', '/usr/sbin'] }
  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $leaked_filenames = $secgen_parameters['leaked_filenames']
  $strings_to_leak = $secgen_parameters['strings_to_leak']
  $username = $secgen_parameters['known_username']
  $password_hash = $secgen_parameters['password_hash'][0]
  $strings_to_pre_leak =  $secgen_parameters['strings_to_pre_leak']
  $web_pre_leak_filename = $secgen_parameters['web_pre_leak_filename'][0]

  # differenitaion in website content generation
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

  exec { 'replace-password':
    command => "sed -i 's/fe01ce2a7fbac8fafaed7c982a04e229/${password_hash}/' /var/www/nanocms/data/pagesdata.txt",
  }

  if $strings_to_pre_leak.length != 0 {
    file{ "/var/www/nanocms/${web_pre_leak_filename}":
      ensure  => file,
      content => template('nanocms_exec//pre_leak.erb')
    }
  }

  file { '/var/www/nanocms/data/areas/website name.php':
    ensure  => file,
    content => template('nanocms_exec//website name.erb'),
  }
  -> file { '/var/www/nanocms/data/areas/website slogan.php':
    ensure  => file,
    content => template('nanocms_exec//website slogan.erb'),
  }
  -> file { '/var/www/nanocms/data/pages/home.php':
    ensure  => file,
    content => template('nanocms_exec//home.erb'),
  }
  -> file { '/var/www/nanocms/data/pages/contact.php':
    ensure  => file,
    content => template('nanocms_exec//contact.erb'),
  }
  -> file { '/var/www/nanocms/data/areas/copyright notice.php':
    ensure  => file,
    content => template('nanocms_exec//copyright notice.erb'),
  }

  ::secgen_functions::leak_files { 'nanocms-flag-leak':
    storage_directory => '/var/www/nanocms/data/pages',
    leaked_filenames  => $leaked_filenames,
    strings_to_leak   => $strings_to_leak,
    owner             => 'www-data',
    mode              => '0750',
    leaked_from       => 'nanocms_exec',
  }
}
