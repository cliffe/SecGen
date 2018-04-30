class moinmoin_195::config {
  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $images_to_leak = $secgen_parameters['images_to_leak']
  $raw_org = $secgen_parameters['organisation']

  if $raw_org and $raw_org[0] and $raw_org[0] != '' {
    $organisation = parsejson($raw_org[0])
    $raw_default_page = regsubst($organisation['business_name'], ',', '', 'G')  # Remove commas from co. names
  } else{
    $raw_default_page = $secgen_parameters['default_page'][0]
  }
  $default_page = regsubst($raw_default_page,' ','(20)', 'G') # replace space with (20) for default pages w/ space.

  # Config files
  file { '/usr/local/share/moin/moin.wsgi':
    ensure => file,
    source => 'puppet:///modules/moinmoin_195/moin.wsgi'
  }

  file { '/usr/local/share/moin/wikiconfig.py':
    ensure => file,
    content  => template('moinmoin_195/wikiconfig.py.erb'),
  }

  # Web server config
  file { '/etc/apache2/apache2.conf':
    ensure => file,
    source => 'puppet:///modules/moinmoin_195/apache2.conf'
  }

  # Set up an article within MoinMoin
  ##  Create outer article directory /usr/local/share/moin/data/pages/NameOfPage/
  file { "/usr/local/share/moin/data/pages/$default_page":
    ensure => directory,
    recurse => true,
    source => 'puppet:///modules/moinmoin_195/WikiSandBox',
    notify => Exec['permissions-moinmoin'],
  }

  ## Leak some data onto the page.
  file { "/usr/local/share/moin/data/pages/$default_page/revisions/00000001":
    ensure => file,
    content => template('moinmoin_195/article.erb'),
  }

  # Leak image
  file { "/usr/local/share/moin/data/pages/$default_page/attachments/":
    ensure => directory,
  }

  ::secgen_functions::leak_files{ 'moinmoin_195-image-leak':
    storage_directory => "/usr/local/share/moin/data/pages/$default_page/attachments",
    images_to_leak => $images_to_leak,
    leaked_from => "moinmoin_195",
  }


  # File permissions + ownership
  exec { 'permissions-moinmoin':
    command => '/bin/chown -R www-data:www-data /usr/local/share/moin;
    /bin/chmod -R ug+rwx /usr/local/share/moin;
    /bin/chmod -R o-rwx /usr/local/share/moin',
    notify => Service['apache2'],
  }
}