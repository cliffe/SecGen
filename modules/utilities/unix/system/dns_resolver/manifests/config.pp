# Points the resolver at fixed nameservers and stops DHCP clients and NetworkManager rewriting
# /etc/resolv.conf, so the setting outlasts the build network's DHCP interface.
# Modules provisioned after this one resolve names through these servers.
class dns_resolver::config {
  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $nameservers = $secgen_parameters['nameservers']

  # dhclient-script sources these hooks; redefining make_resolv_conf leaves resolv.conf alone.
  ensure_resource('file', ['/etc/dhcp', '/etc/dhcp/dhclient-enter-hooks.d'], { ensure => directory })
  file { '/etc/dhcp/dhclient-enter-hooks.d/secgen-static-resolv':
    ensure  => file,
    mode    => '0644',
    content => "# Keep the nameservers set by SecGen's dns_resolver module.\nmake_resolv_conf() { :; }\n",
  }

  ensure_resource('file', ['/etc/NetworkManager', '/etc/NetworkManager/conf.d'], { ensure => directory })
  file { '/etc/NetworkManager/conf.d/90-secgen-dns-none.conf':
    ensure  => file,
    mode    => '0644',
    content => "[main]\ndns=none\n",
  }

  file { '/etc/resolv.conf':
    ensure  => file,
    mode    => '0644',
    content => template('dns_resolver/resolv.conf.erb'),
    require => [File['/etc/dhcp/dhclient-enter-hooks.d/secgen-static-resolv'],
                File['/etc/NetworkManager/conf.d/90-secgen-dns-none.conf']],
  }
}
