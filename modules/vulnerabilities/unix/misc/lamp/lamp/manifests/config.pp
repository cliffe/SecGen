class lamp::config{
  file { '/etc/default/lamp':
    require => Package['lamp'],
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0777',
    content  => template('lamp/lamp.erb')
  }
}