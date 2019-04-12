class xfce_lightdm_root_login::configure {
  case $operatingsystemrelease {
    /^9.*/: { # do 9.x stretch stuff
      exec { 'lightdm-autologin-remove-pam':
        command => "/bin/sed -i \'/auth      required pam_succeed_if.so user != root quiet_success/s/^/#/g\' /etc/pam.d/lightdm-autologin"
      }
      file { '/etc/lightdm/lightdm.conf':
        ensure => present,
        source => 'puppet:///modules/xfce_lightdm_root_login/stretch_lightdm.conf',
      }
    }
    /^7.*/: { # do 7.x wheezy stuff
      exec { 'lightdm-autologin-root':
        command => "/bin/sed -i \'/\\[SeatDefaults\\]/a autologin-user=root\' /etc/lightdm/lightdm.conf"
      }
    }
  }
}
