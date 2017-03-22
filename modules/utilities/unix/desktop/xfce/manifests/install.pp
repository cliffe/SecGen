class xfce::install{

  package { ['xfce4','lightdm']:
    ensure => 'installed',
  }

# exec { 'lightdm-autologin-root':
#   require => Package['lightdm'],
#   command => "/bin/sed -i \'/\\[SeatDefaults\\]/a autologin-user=root\' /etc/lightdm/lightdm.conf"
# }
}
