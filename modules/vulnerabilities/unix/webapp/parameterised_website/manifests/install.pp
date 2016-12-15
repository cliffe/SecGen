class parameterised_website::install {
  $docroot = '/var/www'

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
    ensure => file,
    content => template('parameterised_website/index.html.erb'),
  }

}