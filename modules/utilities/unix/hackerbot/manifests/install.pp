class hackerbot::install{
  # $json_inputs = base64('decode', $::base64_inputs)
  # $secgen_parameters = parsejson($json_inputs)
  # $server_ip = $secgen_parameters['server_ip'][0]
  # $port = $secgen_parameters['port'][0]

  # $hackerbot_xml_configs = []
  # $hackerbot_lab_sheets = []

  file { '/opt/hackerbot':
    ensure => directory,
    recurse => true,
    source => 'puppet:///modules/hackerbot/opt_hackerbot',
    mode   => '0700',
    owner => 'root',
    group => 'root',
  }

  file { '/var/www/labs':
    ensure => directory,
    recurse => true,
    source => 'puppet:///modules/hackerbot/www',
    mode   => '0666',
    owner => 'root',
    group => 'root',
  }

  package { ['nori', 'cinch', 'programr']:
    ensure   => 'installed',
    provider => 'gem',
  }

  package { ['sshpass']:
    ensure   => 'installed',
  }

}
