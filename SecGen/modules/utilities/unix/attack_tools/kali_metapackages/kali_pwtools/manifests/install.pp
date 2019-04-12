class kali_pwtools::install{
  package { ['kali-linux-pwtools']:
    ensure => 'installed',
  }
}
