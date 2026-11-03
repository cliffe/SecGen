# Apache and MySQL are installed by the required modules (services/unix/http/apache
# and database/mysql on Debian, the *_kali_compatible pair on Kali). Enable PHP in
# that Apache and install the PHP MySQL extension so PHP scripts can talk to the
# database.
#
# SecGen applies each module in its own Puppet run, so the apache class (and its
# apache::mod resources and variables) isn't in this catalog, and declaring it here
# would rewrite the config the apache module set up. Debian's libapache2-mod-php
# metapackage pulls in mod_php for whatever PHP version the base ships (7.3 on
# buster, 8.2 on bookworm, Kali's current one) and its postinst switches Apache to
# the prefork MPM and enables the module; the exec below makes sure it is enabled
# with a single MPM, then Apache is restarted to load it.
class lamp::config {
  ensure_packages(['libapache2-mod-php', 'php-mysql'])

  # Enable mod_php without loading a second MPM. The bundled puppetlabs-apache
  # manages prefork as mods-enabled/prefork.load, Debian's packages as
  # mpm_prefork.load, and a2enmod php* pulls in mpm_prefork as a dependency, so
  # with both enabled Apache won't start (on buster: nothing on port 80). Keep
  # whichever prefork is there, drop the other MPM links, and link PHP's
  # .load/.conf directly.
  file { '/usr/local/sbin/lamp-enable-mod-php':
    ensure  => file,
    mode    => '0755',
    content => @(SCRIPT),
      #!/bin/sh
      # Written by SecGen's lamp module (manifests/config.pp).
      cd /etc/apache2/mods-enabled || exit 1
      if [ -e prefork.load ]; then
        rm -f mpm_prefork.load mpm_prefork.conf mpm_event.load mpm_event.conf mpm_worker.load mpm_worker.conf
      elif [ ! -e mpm_prefork.load ]; then
        a2dismod -q mpm_event mpm_worker
        a2enmod -q mpm_prefork
      fi
      for f in ../mods-available/php*.load ../mods-available/php*.conf; do
        [ -e "$f" ] && ln -sf "$f" .
      done
      exit 0
      | SCRIPT
  }

  exec { 'lamp: enable mod_php':
    command => '/usr/local/sbin/lamp-enable-mod-php',
    path    => ['/usr/sbin', '/usr/bin', '/sbin', '/bin'],
    unless  => "/bin/sh -c 'apache2ctl -M 2>/dev/null | grep -q php'",
    require => [Package['libapache2-mod-php'], File['/usr/local/sbin/lamp-enable-mod-php']],
    notify  => Exec['lamp: restart apache'],
  }

  exec { 'lamp: restart apache':
    command     => 'systemctl restart apache2',
    path        => ['/usr/sbin', '/usr/bin', '/sbin', '/bin'],
    refreshonly => true,
    subscribe   => Package['libapache2-mod-php', 'php-mysql'],
  }
}
