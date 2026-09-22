class hackerbot_webclient::config {
  require hackerbot_webclient::install

  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $username       = $secgen_parameters['username'][0]
  $irc_server_ip  = $secgen_parameters['irc_server_ip'][0]
  $hackerbot_nick = $secgen_parameters['hackerbot_nick'][0]

  file { '/opt/hackerbot_webclient/index.html':
    ensure  => file,
    source  => 'puppet:///modules/hackerbot_webclient/index.html',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => File['/opt/hackerbot_webclient'],
  }

  file { '/opt/hackerbot_webclient/app.js':
    ensure  => file,
    source  => 'puppet:///modules/hackerbot_webclient/app.js',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => File['/opt/hackerbot_webclient'],
  }

  # The only templated file: bakes in the per-lab nick/target/server values.
  # index.html and app.js are static and identical across every deployment.
  file { '/opt/hackerbot_webclient/config.js':
    ensure  => file,
    content => template('hackerbot_webclient/config.js.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => File['/opt/hackerbot_webclient'],
  }
}
