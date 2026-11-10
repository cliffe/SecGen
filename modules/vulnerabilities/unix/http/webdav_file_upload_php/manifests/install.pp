# Enable mod_php in the Apache that serves the writable WebDAV collection, so an
# uploaded .php file executes instead of being served as text.
#
# SecGen applies each module in its own Puppet run, so the apache class (and its
# apache::mod resources) are not in this catalogue and must not be referenced.
# The <requires> on the apache service and on apache_webdav_upload order those
# applies first, so by the time this runs Apache is installed, prefork, and the
# WebDAV docroot exists. Debian's libapache2-mod-php metapackage pulls mod_php
# for whatever PHP version the base ships (8.2 on bookworm); the script below
# makes sure it is enabled with a single MPM, then Apache is restarted.
#
# This mirrors the services/unix/http/lamp enable-mod-php approach (without the
# MySQL extension), rather than apache::mod::php, for exactly that reason.
class webdav_file_upload_php::install {
  ensure_packages(['libapache2-mod-php'])

  # Enable mod_php without loading a second MPM. puppetlabs-apache manages
  # prefork as mods-enabled/prefork.load, Debian's packages as mpm_prefork.load,
  # and a2enmod php* pulls in mpm_prefork as a dependency; with both enabled
  # Apache won't start. Keep whichever prefork is present, drop the other MPM
  # links, and link PHP's .load/.conf directly.
  file { '/usr/local/sbin/webdav-enable-mod-php':
    ensure  => file,
    mode    => '0755',
    content => @(SCRIPT),
      #!/bin/sh
      # Written by SecGen's webdav_file_upload_php module (manifests/install.pp).
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

  exec { 'webdav-php: enable mod_php':
    command => '/usr/local/sbin/webdav-enable-mod-php',
    path    => ['/usr/sbin', '/usr/bin', '/sbin', '/bin'],
    unless  => "/bin/sh -c 'apache2ctl -M 2>/dev/null | grep -q php'",
    require => [Package['libapache2-mod-php'], File['/usr/local/sbin/webdav-enable-mod-php']],
    notify  => Exec['webdav-php: restart apache'],
  }

  exec { 'webdav-php: restart apache':
    command     => 'systemctl restart apache2',
    path        => ['/usr/sbin', '/usr/bin', '/sbin', '/bin'],
    refreshonly => true,
    subscribe   => Package['libapache2-mod-php'],
  }
}
