class mirror_traffic_to_ids_iptables::install {
  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $ids_IP_address = $secgen_parameters['ids_IP_address'][0]

  ensure_packages(['iptables-persistent'])

  # force it to not be enabled because the interface in the config may be wrong
  exec { 'save iptables prerouting':
    path     => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ],
    command  => "iptables -t mangle -A PREROUTING -i `ls /sys/class/net | grep lo -v  | head -n1` -j TEE --gateway $ids_IP_address ; iptables-save > /etc/iptables/rules.v4",
    provider => shell,
  }->
  exec { 'save iptables forward':
    path     => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ],
    command  => "iptables -t mangle -A FORWARD -i `ls /sys/class/net | grep lo -v  | head -n1` -j TEE --gateway $ids_IP_address ; iptables-save > /etc/iptables/rules.v4",
    provider => shell,
  }->
  exec { 'save iptables output':
    path     => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ],
    command  => "iptables -t mangle -A OUTPUT -i `ls /sys/class/net | grep lo -v  | head -n1` -j TEE --gateway $ids_IP_address ; iptables-save > /etc/iptables/rules.v4",
    provider => shell,
  }->
  service { 'netfilter-persistent':
    enable => true,
    ensure => 'running',
    provider => systemd,
  }
}
