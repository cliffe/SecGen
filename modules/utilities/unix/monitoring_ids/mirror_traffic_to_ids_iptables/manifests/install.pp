class mirror_traffic_to_ids_iptables::install {
  # ids_IP_address defaults to 192.0.2.1 (TEST-NET-1, RFC 5737) in secgen_metadata.xml so the module always receives an input
  # (no input means no $::base64_inputs_file and get_parameters fails). Real scenarios override it with the IDS address.
  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $ids_IP_address = $secgen_parameters['ids_IP_address'][0]

  ensure_packages(['iptables-persistent'])
  Package['iptables-persistent'] -> Exec['save iptables prerouting']

  # Match every interface except loopback rather than naming one: on Proxmox the
  # first NIC (ens18) is the provisioning NIC, removed after the build, so a rule
  # bound to it never fires. Only INCOMING traffic is mirrored (see metadata), so
  # there is no OUTPUT rule (and -i is invalid in OUTPUT anyway).
  exec { 'save iptables prerouting':
    path     => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ],
    command  => "iptables -t mangle -A PREROUTING ! -i lo -j TEE --gateway $ids_IP_address && iptables-save > /etc/iptables/rules.v4",
    unless   => "iptables -t mangle -C PREROUTING ! -i lo -j TEE --gateway $ids_IP_address",
    provider => shell,
  }->
  exec { 'save iptables forward':
    path     => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ],
    command  => "iptables -t mangle -A FORWARD ! -i lo -j TEE --gateway $ids_IP_address && iptables-save > /etc/iptables/rules.v4",
    unless   => "iptables -t mangle -C FORWARD ! -i lo -j TEE --gateway $ids_IP_address",
    provider => shell,
  }->
  service { 'netfilter-persistent':
    enable => true,
    ensure => 'running',
    provider => systemd,
  }
}
