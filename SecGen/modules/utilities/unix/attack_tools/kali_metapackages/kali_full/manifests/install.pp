class kali_full::install{
  package { ['kali-linux-full']:
    ensure => 'installed',
  }
}
