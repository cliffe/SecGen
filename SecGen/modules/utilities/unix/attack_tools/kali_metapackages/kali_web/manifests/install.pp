class kali_web::install{
  package { ['kali-linux-web']:
    ensure => 'installed',
  }
}
