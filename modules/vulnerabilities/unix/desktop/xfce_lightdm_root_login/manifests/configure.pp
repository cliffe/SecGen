class xfce_lightdm_root_login::configure {
  exec { 'lightdm-autologin-root':
    command => "/bin/sed -i \'/\\[SeatDefaults\\]/a autologin-user=root\' /etc/lightdm/lightdm.conf"
  }
}
