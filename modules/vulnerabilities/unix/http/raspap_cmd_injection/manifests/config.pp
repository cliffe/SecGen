# Class: raspap_cmd_injection::config
# Configure RaspAP in its vulnerable state and set up the CTF challenge
class raspap_cmd_injection::config {
  Exec { path => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ] }
  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $port = $secgen_parameters['port'][0]
  $strings_to_leak = $secgen_parameters['strings_to_leak']
  $leaked_filenames = $secgen_parameters['leaked_filenames']
  $strings_to_pre_leak = $secgen_parameters['strings_to_pre_leak']

  $user = 'www-data'
  $install_dir = '/var/www/raspap'

  # Configure RaspAP - config.php must be in includes/ directory
  # The vulnerable code does: require_once '../../includes/config.php'
  file { "${install_dir}/includes/config.php":
    ensure  => file,
    content => template('raspap_cmd_injection/config.php.erb'),
    owner   => $user,
    group   => $user,
    mode    => '0644',
    require => Class['raspap_cmd_injection::install'],
  }

  # Create raspap.php in config directory (required by index.php)
  file { "${install_dir}/config/raspap.php":
    ensure  => file,
    content => template('raspap_cmd_injection/raspap.php.erb'),
    owner   => $user,
    group   => $user,
    mode    => '0644',
    require => Class['raspap_cmd_injection::install'],
  }

  # Configure lighttpd
  file { '/etc/lighttpd/lighttpd.conf':
    ensure  => file,
    content => template('raspap_cmd_injection/lighttpd.conf.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    notify  => Service['lighttpd'],
  }

  # Create vulnerable OpenVPN configuration directory
  exec { 'create-openvpn-dir':
    command => 'mkdir -p /etc/openvpn/client',
    creates => '/etc/openvpn/client',
  }

  # Create a dummy OpenVPN config for realism
  file { '/etc/openvpn/client/example.ovpn':
    ensure  => file,
    content => "# Dummy OpenVPN configuration for realism\n",
    owner   => 'root',
    mode    => '0644',
    require => Exec['create-openvpn-dir'],
  }

  # Create pre-leak page with hints
  file { "${install_dir}/index.html":
    ensure  => file,
    content => template('raspap_cmd_injection/index.html.erb'),
    owner   => $user,
    mode    => '0644',
    require => Class['raspap_cmd_injection::install'],
  }

  # Set log directory permissions
  exec { 'set-log-perms':
    command => 'chmod 755 /var/log/lighttpd',
    require => Class['raspap_cmd_injection::install'],
  }

  # Leak flag files for students to find
  ::secgen_functions::leak_files { 'raspap-file-leak':
    storage_directory => '/var/www',
    leaked_filenames  => $leaked_filenames,
    strings_to_leak   => $strings_to_leak,
    owner             => $user,
    mode              => '0600',
    leaked_from       => 'raspap_cmd_injection',
  }
}
