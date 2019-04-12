class parameterised_website::install {
  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)

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
  } else {
    $business_name = ''
    $business_motto = ''
    $manager_profile = ''
    $business_address = ''
    $office_telephone = ''
    $office_email = ''
    $industry = ''
    $product_name = ''
    $employees = []
    $intro_paragraph = []
  }

  $strings_to_leak = $secgen_parameters['strings_to_leak']
  $images_to_leak = $secgen_parameters['images_to_leak']

  $security_audit = $secgen_parameters['security_audit']
  $acceptable_use_policy = str2bool($secgen_parameters['host_acceptable_use_policy'][0])

  $visible_tabs = $secgen_parameters['visible_tabs']
  $hidden_tabs = $secgen_parameters['hidden_tabs']

  $white_text = $secgen_parameters['white_text']

  if $intro_paragraph != [] and $intro_paragraph != '' {
    $main_page_paragraph_content = $intro_paragraph
  } else {
    $main_page_paragraph_content = $secgen_parameters['main_page_paragraph_content']
  }

  # Additional Pages
  $additional_pages = $secgen_parameters['additional_pages']
  $additional_page_filenames = $secgen_parameters['additional_page_filenames']

  $docroot = '/var/www/parameterised_website'

  if $acceptable_use_policy {  # Use alternative intranet index.html template
    $index_template = 'parameterised_website/intranet_index.html.erb'
  } else {
    $index_template = 'parameterised_website/index.html.erb'
  }

  file { $docroot:
    ensure => directory,
  }

  # Move boostrap css+js over
  file { "$docroot/css":
    ensure => directory,
    recurse => true,
    source => 'puppet:///modules/parameterised_website/css',
    require => File[$docroot],
  }
  file { "$docroot/js":
    ensure => directory,
    recurse => true,
    source => 'puppet:///modules/parameterised_website/js',
    require => File[$docroot],
  }

  # Apply default CSS template
  file { "$docroot/css/default.css":
    ensure => file,
    content => template('parameterised_website/default.css.erb'),
    require => File["$docroot/css"],
  }

  # Add randomly selected CSS theme
  file { "$docroot/css/$theme":
    ensure => file,
    source => "puppet:///modules/parameterised_website/themes/$theme",
    require => File[$docroot],
  }

  # Apply index page template
  file { "$docroot/index.html":
    ensure  => file,
    content => template($index_template),
    require => File[$docroot],
  }

  if $organisation and $organisation != ''{
    # Apply contact page template
    file { "$docroot/contact.html":
      ensure  => file,
      content => template('parameterised_website/contact.html.erb'),
    }
  }

  # Create visible tab html files
  unless $visible_tabs == undef {
    $visible_tabs.each |$counter, $visible_tab| {
      if $counter != 0 {
        $n = $counter

        file { "$docroot/tab_$n.html":
          ensure  => file,
          content => $visible_tab,
        }
      }
    }
  }

  # Create hidden tab html files
  unless $hidden_tabs == undef {
    $hidden_tabs.each |$counter, $hidden_tab| {
      if $counter == 0 {
        $n = 0
      } else {
        $n = $counter + $visible_tabs.length - 1  # minus one accounts for the information tab
      }

      file { "$docroot/tab_$n.html":
        ensure  => file,
        content => $hidden_tab,
      }
    }
  }

  if $images_to_leak {
    ::secgen_functions::leak_files{ 'parameterised_website-image-leak':
      storage_directory => $docroot,
      images_to_leak => $images_to_leak,
      leaked_from => "parameterised_website",
    }
  }

  if $additional_pages and $additional_page_filenames {
    $additional_page_pairs = zip($additional_pages, $additional_page_filenames)
    $additional_page_pairs.each |$additional_page_pair|{
      $additional_page_contents = $additional_page_pair[0]
      $additional_page_filename = $additional_page_pair[1]

      file { "$docroot/$additional_page_filename":
        ensure  => file,
        content => template('parameterised_website/page.html.erb'),
      }
    }
  }

  if $acceptable_use_policy {
    # Apply template
    file{ "$docroot/acceptable_use_policy.html":
      ensure  => file,
      content => template('parameterised_website/acceptable_use_page.html.erb')
    }
  }

  # Security audit remit
  if $security_audit {
    $security_audit_remit = $security_audit[0]

    # Apply template
    file{ "$docroot/security_audit_remit.html":
      ensure  => file,
      content => template('parameterised_website/security_audit_remit_page.html.erb'),

    }
  }

}