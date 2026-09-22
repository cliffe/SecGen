class hackerbot_webclient::config {
  require hackerbot_webclient::install

  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $username       = $secgen_parameters['username'][0]
  $irc_server_ip  = $secgen_parameters['irc_server_ip'][0]
  $hackerbot_nick = $secgen_parameters['hackerbot_nick'][0]

  file { '/opt/hackerbot_webclient/index.html':
    ensure  => file,
    content => template('hackerbot_webclient/index.html.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => File['/opt/hackerbot_webclient'],
  }
}
