class iptables_rules::install {
  package { 'iptables-persistent':
    ensure => installed,
  }
}