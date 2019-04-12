class kali_top10::install{
  package { ['kali-linux-top10']:
    ensure => 'installed',
  }
}
