# Class: nanocms
#
#
class nanocms_exec::configure {
  $leaked_filenames = ['flagtest'] ##$secgen_parameters['leaked_filenames']
  $strings_to_leak = ['this is a list of strings that are secrets / flags','another secret'] ##$secgen_parameters['strings_to_leak']
  $known_username = 'admin' ##$secgen_parameters['known_username'][0]
  $known_password = 'demo' ##$secgen_parameters['known_password'][0]
  $strings_to_pre_leak =  ['The username is admin', 'The password is demo'] ##$secgen_parameters['strings_to_pre_leak']
  $web_pre_leak_filename = 'PRELEAK_NAME' ##$secgen_parameters['web_pre_leak_filename'][0]

  # differenitaion in website content generation
  $raw_org = '{"business_name":"Artisan Bakery","business_motto":"The loaves are in the oven.","business_address":"1080 Headingley Lane, Headingley, Leeds, LS6 1BN","domain":"artisan-bakery.co.uk","office_telephone":"0113 222 1080","office_email":"orders@artisan-bakery.co.uk","industry":"Bakers","manager":{"name":"Maxie Durgan","address":"1080 Headingley Lane, Headingley, Leeds, LS6 1BN","phone_number":"07645 289149","email_address":"maxie@artisan-bakery.co.uk","username":"maxie","password":""},"employees":[{"name":"Matthew Riley","address":"1080 Headingley Lane, Headingley, Leeds, LS6 1BN","phone_number":"07876 518651","email_address":"matt@artisan-bakery.co.uk","username":"matt","password":""},{"name":"Emelie Lowe","address":"1080 Headingley Lane, Headingley, Leeds, LS6 1BN","phone_number":"07560 246931","email_address":"emelie@artisan-bakery.co.uk","username":"emelie","password":""},{"name":"Antonio Durgan","address":"1080 Headingley Lane, Headingley, Leeds, LS6 1BN","phone_number":"07943 250930","email_address":"antonio@artisan-bakery.co.uk","username":"antonio","password":""}],"product_name":"Baked goods","intro_paragraph":["Finest bakery in Headingley since 1900. Baked fresh daily. Bread loaves, teacakes, sweet and savoury treats. We are open from 9 am til 6 pm, every day except for bank holidays."]}'
  ##$secgen_parameters['organisation'][0]
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

  Exec { path => ['/bin', '/usr/bin', '/usr/local/bin', '/sbin', '/usr/sbin'] }

  ::secgen_functions::leak_files { 'nanocms-flag-leak':
    storage_directory => '/var/www/nanocms/data/pages',
    leaked_filenames  => $leaked_filenames,
    strings_to_leak   => $strings_to_leak,
    owner             => 'www-data',
    mode              => '0750',
    leaked_from       => 'nanocms_exec',
  }
}
