class wordpress::conf ($version){
  file { '/wordpress_conf.sh':
    owner   => 'root',
    group   => 'root',
    ensure  => present,
    mode    => '0755',
    content => template('wordpress/wordpress_conf.sh.erb'),
  }

#  exec { 'run wordpress config script':
#    command => '/bin/bash /tmp/wordpress_conf.sh',
#    require => File['/tmp/wordpress_conf.sh'],
#  }
}
