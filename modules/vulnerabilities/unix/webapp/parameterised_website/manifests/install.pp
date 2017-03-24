class parameterised_website::install {
  $json_inputs = base64('decode', $::base64_inputs)
  $secgen_parameters = parsejson($json_inputs)

  # Parse out parameters
  $business_name = $secgen_parameters['business_name'][0]
  $business_motto = $secgen_parameters['business_motto'][0]
  $manager_profile = parsejson($secgen_parameters['manager_profile'][0])
  $business_address = $secgen_parameters['business_address'][0]
  $office_telephone = $secgen_parameters['office_telephone'][0]
  $office_email = $secgen_parameters['office_email'][0]
  $industry = $secgen_parameters['industry'][0]
  $product_name = $secgen_parameters['product_name'][0]
  $employees = $secgen_parameters['employees']
  $strings_to_leak = $secgen_parameters['strings_to_leak']
  $main_page_paragraph_content = $secgen_parameters['main_page_paragraph_content']
  $images_to_leak = $secgen_parameters['images_to_leak']

  $security_audit = $secgen_parameters['security_audit']
  $acceptable_use_policy = str2bool($secgen_parameters['host_acceptable_use_policy'][0])
  $docroot = '/var/www'

  if $acceptable_use_policy {  # Use alternative intranet index.html template
    $index_template = 'parameterised_website/intranet_index.html.erb'
  } else {
    $index_template = 'parameterised_website/index.html.erb'
  }

  # Move boostrap css+js over
  file { "$docroot/css":
    ensure => directory,
    recurse => true,
    source => 'puppet:///modules/parameterised_website/css',
  }
  file { "$docroot/js":
    ensure => directory,
    recurse => true,
    source => 'puppet:///modules/parameterised_website/js',
  }

  # Apply default CSS template
  file { "$docroot/css/default.css":
  ensure => file,
  content => template('parameterised_website/default.css.erb')
  }

  # Apply index page template
  file { "$docroot/index.html":
    ensure  => file,
    content => template($index_template),
  }

  # Apply contact page template
  file { "$docroot/contact.html":
    ensure  => file,
    content => template('parameterised_website/contact.html.erb'),
  }

  ::secgen_functions::leak_files{ 'parameterised_website-image-leak':
    storage_directory => $docroot,
    images_to_leak => $images_to_leak,
    leaked_from => "parameterised_website",
  }
}