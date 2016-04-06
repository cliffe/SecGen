# Setup the site
wp::site {'store':
  location => '/var/www/wordpress',
  url => 'http://wordpress.local',
  name => 'Test Site'
}
wp::rewrite {'/%post_id%/%postname%/':
  # structure => '/%post_id%/%postname%/',
  location => $location,
  require => Wp::Site['store']
}

# Set the options to their required values
wp::option {'timezone_string':
  # key => 'timezone_string',
  value => 'Australia/Brisbane',
  location => $location,
  require => Wp::Site['store']
}
wp::option {'update_core':
  # key => 'update_core',
  ensure => absent,
  location => $location,
  require => Wp::Site['store']
}

# Setup themes and plugins
wp::theme {'twentythirteen':
  location => '/vagrant/wp',
  require => Wp::Site['store'],
}
wp::plugin {'woocommerce':
  # ensure => enabled,
  location => '/vagrant/wp',
  require => Wp::Site['store'],
}
wp::plugin {'debug-bar':
  ensure => disabled,
  location => '/vagrant/wp',
  require => Wp::Site['store'],
}
