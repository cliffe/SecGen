class hackerbot::config{
  require hackerbot::install

  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $port = $secgen_parameters['port'][0]

  $hackerbot_xml_configs = []
  $hackerbot_lab_sheets = []

  $secgen_parameters['hackerbot_configs'].each |$counter, $config_pair| {
    $parsed_pair = parsejson($config_pair)

    notice("Creating bot config")
    $xmlfilename = "bot_$counter.xml"

    file { "/opt/hackerbot/config/$xmlfilename":
      ensure => present,
      content => $parsed_pair['xml_config'],
      mode   => '0600',
      owner => 'root',
      group => 'root',
    }

    if $secgen_parameters['hackerbot_configs'].length == 1 {
      $htmlfilename = "index.html"
    } else {
      $htmlfilename = "lab_part_$counter.html"
    }

    file { "/var/www/labs/$htmlfilename":
      ensure => present,
      content => $parsed_pair['html_lab_sheet'],
    }

  }

  class { '::apache':
    default_vhost => false,
    # overwrite_ports => false,
  }
  apache::vhost { 'vhost.labs.com':
    port    => "$port",
    docroot => '/var/www/labs',
  }


}
