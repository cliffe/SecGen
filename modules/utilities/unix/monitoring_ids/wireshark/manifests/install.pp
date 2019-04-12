class wireshark::install{
  package { ['wireshark', 'tcpdump']:
    ensure => 'installed',
  }
}
