class wireshark::install{
  package { ['wireshark', 'tshark', 'tcpdump']:
    ensure => 'installed',
  }
}
