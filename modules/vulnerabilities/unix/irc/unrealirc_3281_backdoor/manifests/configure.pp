class unrealirc_3281_backdoor::configure {
  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $port = $secgen_parameters['port'][0]
  $strings_to_leak = $secgen_parameters['strings_to_leak']
  $leaked_filenames = $secgen_parameters['leaked_filenames']
  $user = $secgen_parameters['user'][0]
  $group = $secgen_parameters['group'][0]
  $user_home = "/home/$user"
  $raw_org = $secgen_parameters['organisation']

  if $raw_org and $raw_org[0] and $raw_org[0] != '' {
    $organisation = parsejson($raw_org[0])
    $business_name = $organisation['business_name']
    $motd = "Welcome to the $business_name irc server!"
  }
  else{
    $motd = $secgen_parameters['motd'][0]
  }

  Exec { path => ['/bin', '/usr/bin', '/usr/local/bin', '/sbin', '/usr/sbin'], }

  file { '/etc/init.d/unreal':
    ensure   => file,
    mode     => '0755',
    content  => template('unrealirc_3281_backdoor/unreal.erb'),
  }

  file { '/var/lib/unreal/unrealircd.conf':
    ensure   => file,
    mode     => '0600',
    content  => template('unrealirc_3281_backdoor/unrealircd.conf.erb'),
  }

  exec { 'update_unreal_3281_port':
    command => "/bin/echo 'listen *:$port;' > /var/lib/unreal/config/listen_default_6667.conf; service unreal restart",
  }

  # Update message of the day w/ param
  file { '/var/lib/unreal/ircd.motd2':
    ensure => file,
    content => $motd
  }

  exec { 'update-motd':
    cwd => '/var/lib/unreal/',
    command => 'cat ircd.motd2 > ircd.motd'
  }

  # Create $user_home dir
  file { $user_home:
    ensure => directory,
  }

  ::secgen_functions::leak_files { 'unrealirc_3281-file-leak':
    storage_directory => $user_home,
    leaked_filenames  => $leaked_filenames,
    strings_to_leak   => $strings_to_leak,
    owner             => $user,
    leaked_from       => "unrealirc_3281_backdoor",
    mode              => '0600'
  }
}