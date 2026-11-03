class apparmor::install {

  #$secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  #$chroot_dir = $secgen_parameters['chroot_dir'][0]

  package { ['apparmor', 'apparmor-easyprof', 'apparmor-notify', 'apparmor-profiles', 'apparmor-profiles-extra', 'apparmor-utils', 'auditd']:
    ensure => 'installed',
  } ->

  # the default pidgin AppArmor profile breaks our pidgin module (images etc)
  file { "/etc/apparmor.d/usr.bin.pidgin":
    ensure => 'absent',
  } ->

  # tier 2 expects the apparmor unit to be active after the post-build reboot;
  # enable only (no ensure => running), as the unit is skipped by its
  # ConditionSecurity until the running kernel has AppArmor switched on
  service { 'apparmor':
    enable => true,
  } ->

  file { "/etc/default/grub.d":
    ensure => 'directory',
  } ->

  file { "/etc/default/grub.d/apparmor.cfg":
    content => "GRUB_CMDLINE_LINUX_DEFAULT=\"\$GRUB_CMDLINE_LINUX_DEFAULT apparmor=1 security=apparmor\"\n",
  } ->

  exec { "sudo update-grub":
    cwd     => '/var/tmp',
    provider     => 'shell',
    path  => ['/bin', '/usr/bin', '/usr/sbin', '/sbin',],
  } ->

  # work around for bug in Debian Buster
  exec { "sudo touch /etc/apparmor.d/local/usr.lib.dovecot.imap-login /etc/apparmor.d/local/usr.lib.dovecot.imap /etc/apparmor.d/local/usr.lib.dovecot.managesieve /etc/apparmor.d/local/usr.lib.dovecot.anvil /etc/apparmor.d/local/usr.lib.dovecot.deliver /etc/apparmor.d/local/usr.lib.dovecot.auth /etc/apparmor.d/local/usr.lib.dovecot.config /etc/apparmor.d/local/usr.lib.dovecot.ssl-params /etc/apparmor.d/local/usr.lib.dovecot.managesieve-login /etc/apparmor.d/local/usr.lib.dovecot.dict /etc/apparmor.d/local/usr.sbin.dovecot /etc/apparmor.d/local/usr.lib.dovecot.log /etc/apparmor.d/local/usr.lib.dovecot.dovecot-lda /etc/apparmor.d/local/usr.lib.dovecot.pop3-login /etc/apparmor.d/local/usr.lib.dovecot.pop3 /etc/apparmor.d/local/usr.lib.dovecot.dovecot-auth /etc/apparmor.d/local/usr.lib.dovecot.lmtp":
    provider     => 'shell',
    path  => ['/bin', '/usr/bin', '/usr/sbin', '/sbin',],
  }


}
