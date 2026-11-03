class bind9::config {
  $secgen_params  = secgen_functions::get_parameters($::base64_inputs_file)
  $domain         = $secgen_params['domain'][0]
  $ns_hostname    = $secgen_params['ns_hostname'][0]
  $serial         = $secgen_params['serial'][0]
  $dns_records    = $secgen_params['dns_records']
  $allow_transfer = $secgen_params['allow_transfer'][0]

  # Address for the name server's own A record. Bind refuses a zone whose NS
  # target is in-zone but has no address, so zone.db.erb adds one when
  # dns_records does not. Falls back to loopback if the fact is missing.
  $ns_ip = $facts['networking']['ip'] ? {
    undef   => '127.0.0.1',
    default => $facts['networking']['ip'],
  }

  # dns_records entries are parsed in templates/zone.db.erb: "hostname|type|value",
  # "hostname|type|value|priority" (MX), or legacy "hostname=ip" (A record).

  file { '/etc/bind/named.conf.options':
    ensure  => present,
    owner   => 'root',
    group   => 'bind',
    mode    => '0644',
    content => template('bind9/named.conf.options.erb'),
    require => Package['bind9'],
    notify  => Service['bind9'],
  }

  file { '/etc/bind/named.conf.local':
    ensure  => present,
    owner   => 'root',
    group   => 'bind',
    mode    => '0644',
    content => template('bind9/named.conf.local.erb'),
    require => Package['bind9'],
    notify  => Service['bind9'],
  }

  file { "/etc/bind/db.${domain}":
    ensure  => present,
    owner   => 'root',
    group   => 'bind',
    mode    => '0644',
    content => template('bind9/zone.db.erb'),
    require => Package['bind9'],
    notify  => Service['bind9'],
  }

}
