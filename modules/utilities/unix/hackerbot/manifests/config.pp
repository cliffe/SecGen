class hackerbot::config{
  require hackerbot::install

  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $ssh_key_pair  = parsejson($secgen_parameters['ssh_key_pair'][0])
  $private_key   = $ssh_key_pair['private']

  # Only JSON values are bot configs; the metadata default ("localhost") is a placeholder
  $bot_configs = $secgen_parameters['hackerbot_configs'] ? {
    undef   => [],
    default => $secgen_parameters['hackerbot_configs'].filter |$c| { $c =~ /^\s*\{/ },
  }

  $bot_configs.each |$counter, $config_pair| {
    $parsed_pair = parsejson($config_pair)

    notice("Creating bot config")
    $xmlfilename = "bot_$counter.xml"

    file { "/opt/hackerbot/config/$xmlfilename":
      ensure  => present,
      content => $parsed_pair['xml_config'],
      mode    => '0600',
      owner   => 'root',
      group   => 'root',
      require => File['/opt/hackerbot'],
    }
  }

  # With no bot configured the process would exit at once, so install a minimal bot
  if empty($bot_configs) {
    file { '/opt/hackerbot/config/bot_0.xml':
      ensure  => present,
      source  => 'puppet:///modules/hackerbot/default_bot.xml',
      mode    => '0600',
      owner   => 'root',
      group   => 'root',
      require => File['/opt/hackerbot'],
    }
  }

    file { '/opt/hackerbot/keys':
      ensure  => directory,
      owner   => 'root',
      group   => 'root',
      mode    => '0700',
      require => File['/opt/hackerbot'],
    }

    # Private key used by hackerbot Ruby process for all SSH connections
    file { '/opt/hackerbot/keys/id_rsa':
      ensure  => file,
      owner   => 'root',
      group   => 'root',
      mode    => '0600',
      content => $private_key,
      require => File['/opt/hackerbot/keys'],
    }
}
