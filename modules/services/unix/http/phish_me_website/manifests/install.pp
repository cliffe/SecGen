class phish_me_website::install {
  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)

  $docroot = '/var/www/accountingnow'

  # file { $docroot:
  #   ensure => directory,
  # }

  # Move boostrap css+js over
  file { "$docroot/":
    ensure => directory,
    recurse => true,
    source => 'puppet:///modules/phish_me_website/www',
    # require => File[$docroot],
  }

  # apply.php stores uploaded CVs here
  file { "$docroot/Action/uploads":
    ensure  => directory,
    owner   => 'www-data',
    mode    => '0775',
    require => File["$docroot/"],
  }
}
