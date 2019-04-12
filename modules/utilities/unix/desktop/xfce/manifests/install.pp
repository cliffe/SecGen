class xfce::install{
  package { ['xfce4','lightdm']:
    ensure => 'installed',
  }
}
