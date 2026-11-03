class iptables_rules::config {
  $secgen_params = secgen_functions::get_parameters($::base64_inputs_file)

  $rules         = $secgen_params['rules']
  $ip_forwarding = $secgen_params['ip_forwarding'][0]

  if $rules == undef or length($rules) == 0 {
    fail('iptables_rules: no rules provided, at least one rule is required.')
  }

  # rules.v4.erb sorts the rules into tables ('-t <table>' prefix, default filter)
  # and turns '-P CHAIN POLICY' into the chain's policy declaration.

  file { '/etc/iptables':
    ensure => directory,
  }

  file { '/etc/iptables/rules.v4':
    ensure  => present,
    content => template('iptables_rules/rules.v4.erb'),
    require => [File['/etc/iptables'], Package['iptables-persistent']],
  }

  # netfilter-persistent restores rules.v4 at boot; make sure it is enabled
  service { 'netfilter-persistent':
    enable  => true,
    require => Package['iptables-persistent'],
  }

  if $ip_forwarding == 'true' {
    file_line { 'enable_ip_forward':
      path  => '/etc/sysctl.conf',
      line  => 'net.ipv4.ip_forward=1',
      match => '^#?net\.ipv4\.ip_forward',
    }

    exec { 'apply_ip_forward':
      command     => '/sbin/sysctl -p',
      refreshonly => true,
      subscribe   => File_line['enable_ip_forward'],
    }
  }
}