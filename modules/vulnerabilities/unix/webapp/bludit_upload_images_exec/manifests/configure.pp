class bludit_upload_images_exec::configure {
  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $leaked_filenames = $secgen_parameters['leaked_filenames']
  $strings_to_leak = $secgen_parameters['strings_to_leak']
  $known_username = $secgen_parameters['known_username'][0]
  $known_password = $secgen_parameters['known_password'][0]
  $strings_to_pre_leak = $secgen_parameters['strings_to_pre_leak']
  $web_pre_leak_filename = $secgen_parameters['web_pre_leak_filename'][0]
  # $images_to_leak = $secgen_parameters['images_to_leak']

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

  if $strings_to_pre_leak.length != 0 {
  	file{ "/var/www/bludit-3-9-2/$web_pre_leak_filename":
  		ensure => file,
  		content => template('bludit_upload_images_exec/pre_leak.erb')
  	}
  }


  Exec { path => ['/bin', '/usr/bin', '/usr/local/bin', '/sbin', '/usr/sbin'] }

  # install.php requires a password >= 6 chars, but weak_password_generator
  # produces 3-5-char words.  Bypass install.php entirely: create the
  # bl-content directory tree and database files directly.  users.php is
  # written from a template that SHA1-hashes $known_password (any length).
  exec { 'create-bludit-directories':
    command  => 'mkdir -p /var/www/bludit-3-9-2/bl-content/databases/plugins/tinymce /var/www/bludit-3-9-2/bl-content/databases/plugins/about /var/www/bludit-3-9-2/bl-content/databases/plugins/simple-stats /var/www/bludit-3-9-2/bl-content/databases/plugins/robots /var/www/bludit-3-9-2/bl-content/databases/plugins/canonical /var/www/bludit-3-9-2/bl-content/pages/about /var/www/bludit-3-9-2/bl-content/uploads/profiles /var/www/bludit-3-9-2/bl-content/uploads/thumbnails /var/www/bludit-3-9-2/bl-content/uploads/pages /var/www/bludit-3-9-2/bl-content/workspaces /var/www/bludit-3-9-2/bl-content/tmp && chown -R www-data: /var/www/bludit-3-9-2/bl-content',
    provider => 'shell',
    creates  => '/var/www/bludit-3-9-2/bl-content/databases',
  } ->

  file { '/var/www/bludit-3-9-2/bl-content/databases/users.php':
    ensure  => file,
    owner   => 'www-data',
    group   => 'www-data',
    content => template('bludit_upload_images_exec/users.php.erb'),
  } ->

  file { '/var/www/bludit-3-9-2/bl-content/databases/security.php':
    ensure  => file,
    owner   => 'www-data',
    group   => 'www-data',
    content => "<?php defined('BLUDIT') or die('Bludit CMS.'); ?>\n{\n   \"minutesBlocked\": 5,\n   \"numberFailuresAllowed\": 10,\n   \"blackList\": []\n}\n",
  } ->

  file { '/var/www/bludit-3-9-2/bl-content/databases/syslog.php':
    ensure  => file,
    owner   => 'www-data',
    group   => 'www-data',
    content => "<?php defined('BLUDIT') or die('Bludit CMS.'); ?>\n[]\n",
  } ->

  file { '/var/www/bludit-3-9-2/bl-content/databases/categories.php':
    ensure  => file,
    owner   => 'www-data',
    group   => 'www-data',
    content => "<?php defined('BLUDIT') or die('Bludit CMS.'); ?>\n{\n   \"general\": {\"name\": \"General\", \"description\": \"\", \"template\": \"\", \"list\": []}\n}\n",
  } ->

  file { '/var/www/bludit-3-9-2/bl-content/databases/tags.php':
    ensure  => file,
    owner   => 'www-data',
    group   => 'www-data',
    content => "<?php defined('BLUDIT') or die('Bludit CMS.'); ?>\n{}\n",
  } ->

  # manually place website contents via templates
	file{ "/var/www/bludit-3-9-2/bl-content/databases/site.php":
		ensure => file,
		content => template('bludit_upload_images_exec/site.php.erb')
	} ->
	file{ "/var/www/bludit-3-9-2/bl-content/databases/pages.php":
		ensure => file,
		content => template('bludit_upload_images_exec/pages.php.erb')
	} ->
	file{ "/var/www/bludit-3-9-2/bl-content/pages/about/index.txt":
		ensure => file,
		content => template('bludit_upload_images_exec/about.erb')
	} ->
	file{ "/var/www/bludit-3-9-2/bl-content/databases/plugins/about/db.php":
		ensure => file,
		content => template('bludit_upload_images_exec/about_sidebar.php.erb')
	} ->
	file{ "/var/www/bludit-3-9-2/bl-content/pages/what-we-do/":
		ensure => directory,
	} ->
	file{ "/var/www/bludit-3-9-2/bl-content/pages/what-we-do/index.txt":
		ensure => file,
		content => template('bludit_upload_images_exec/what-we-do.erb')
	} ->
  # the user that is created on install gets called admin, even when specifying another name, this fixes that
  exec { 'fix-admin-username-bludit':
    command => "sed -i 's/\"admin\":/\"$known_username\":/g' /var/www/bludit-3-9-2/bl-content/databases/users.php",
    provider => 'shell',
    logoutput => true
  }

  # CVE-2019-16113 exploit uploads a .png webshell to bl-content/tmp/ and
  # triggers it via Apache.  PHP-FPM's security.limit_extensions defaults to
  # ".php", so it rejects .png with "Access denied".  Extend it to also allow
  # .png so FPM executes the uploaded file when Apache proxies the request.
  # php7_patched runs as its own module earlier in provisioning, so its class and
  # fpm service are not in this catalog; the config file already exists. Edit it
  # and restart fpm directly rather than with a cross-module require/notify.
  file_line { 'fpm-security-limit-extensions':
    path  => '/opt/php-7.4-patched/etc/php-fpm.d/www.conf',
    line  => 'security.limit_extensions = .php .png',
    match => '^security\.limit_extensions',
  }
  ~> exec { 'bludit-restart-php7-patched-fpm':
    command     => 'systemctl restart php7-patched-fpm',
    path        => ['/usr/bin', '/usr/sbin', '/bin', '/sbin'],
    refreshonly => true,
  }

  ::secgen_functions::leak_files { 'bludit-flag-leak':
    storage_directory => '/var/www/bludit-3-9-2/bl-content/tmp',
    leaked_filenames  => $leaked_filenames,
    strings_to_leak   => $strings_to_leak,
    owner             => 'www-data',
    mode              => '0750',
    leaked_from       => 'bludit_upload_images_exec',
  }


}
