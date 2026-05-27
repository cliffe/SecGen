class hackerbot::config{
  require hackerbot::install

  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $port = $secgen_parameters['port'][0]
  $ssh_key_pair  = parsejson($secgen_parameters['ssh_key_pair'][0])
  $private_key   = $ssh_key_pair['private']


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


  class { '::apache':
    default_vhost => false,
    # overwrite_ports => false,
  }
  apache::vhost { 'vhost.labs.com':
    port    => "$port",
    docroot => '/var/www/labs',
    notify => Tidy['hb remove default site']
  }

  ensure_resource('tidy','hb remove default site', {'path'=>'/etc/apache2/sites-enabled/000-default.conf'})

  # not sure why the new kali apache module doesn't start on boot, this fixes it
  exec { 'hackerbot-apache2-systemd-reload':
    command     => 'systemctl daemon-reload; systemctl enable apache2',
    path        => [ '/usr/bin', '/bin', '/usr/sbin' ],
  }
}
