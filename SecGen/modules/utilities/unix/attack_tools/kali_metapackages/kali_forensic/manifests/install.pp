class kali_forensic::install{
  package { ['kali-linux-forensic']:
    ensure => 'installed',
  }
}
