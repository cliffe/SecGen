class bind9::config {
  $secgen_params  = secgen_functions::get_parameters($::base64_inputs_file)
  $domain         = $secgen_params['domain'][0]
  $ns_hostname    = $secgen_params['ns_hostname'][0]
  $serial         = $secgen_params['serial'][0]
  $dns_records    = $secgen_params['dns_records']
  $allow_transfer = $secgen_params['allow_transfer'][0]

  # Parse dns_records entries in the format "hostname|type|value" or
  # "hostname|type|value|priority" (MX only).
  # Also accepts legacy "hostname=ip" format (treated as A records).
  $dns_record_pairs = inline_template('<%
result = []
(@dns_records || []).each do |r|
  if r.include?("|")
    parts = r.split("|")
    entry = { "hostname" => parts[0], "type" => parts[1].upcase, "value" => parts[2] }
    entry["priority"] = parts[3] if parts[3]
    result << entry
  elsif r.include?("=")
    parts = r.split("=")
    result << { "hostname" => parts[0], "type" => "A", "value" => parts[1] }
  end
end
-%><%= result %>')

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
