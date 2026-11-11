# Enable CGI execution for scripts uploaded into the writable WebDAV collection,
# via mod_actions + a dispatcher so the uploaded file does not need the execute
# bit (a WebDAV PUT writes mode 0644). See files/webdav-cgi-exec.conf.
#
# SecGen applies each module in its own Puppet run, so the apache class and its
# File['/etc/apache2/conf.d'] are not in this catalogue and must not be
# referenced. The <requires> on the apache service and on apache_webdav_upload
# order those applies first, so the conf.d directory and the WebDAV docroot
# already exist on disk by the time this runs. This mirrors the conf.d-drop used
# by services/unix/http/apache_bash_cgi.
class webdav_file_upload_cgi::install {

  # mod_cgi runs the dispatcher; mod_actions maps uploaded scripts to it. Both
  # are enabled explicitly so this module does not depend on the apache module's
  # defaults. Idempotent.
  exec { 'webdav-cgi: enable mod_cgi + mod_actions':
    command => 'a2enmod -q cgi actions',
    path    => ['/usr/sbin', '/usr/bin', '/sbin', '/bin'],
    unless  => '/bin/sh -c "apache2ctl -M 2>/dev/null | grep -q actions_module && apache2ctl -M 2>/dev/null | grep -qE \'cgi_module|cgid_module\'"',
    notify  => Exec['webdav-cgi: restart apache'],
  }

  file { '/usr/lib/secgen-dav-cgi-bin':
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  # The dispatcher CGI (executable; the uploaded scripts need not be).
  file { '/usr/lib/secgen-dav-cgi-bin/dispatch':
    ensure  => file,
    source  => 'puppet:///modules/webdav_file_upload_cgi/dispatch',
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    require => File['/usr/lib/secgen-dav-cgi-bin'],
    notify  => Exec['webdav-cgi: restart apache'],
  }

  # The <DirectoryMatch> snippet that adds ExecCGI + the handler/action for
  # /var/www/webdav, plus the ScriptAlias for the dispatcher.
  file { '/etc/apache2/conf.d/webdav-cgi-exec.conf':
    ensure  => file,
    source  => 'puppet:///modules/webdav_file_upload_cgi/webdav-cgi-exec.conf',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => File['/usr/lib/secgen-dav-cgi-bin/dispatch'],
    notify  => Exec['webdav-cgi: restart apache'],
  }

  # Restart apache so it loads the modules and reads the new snippet. refreshonly
  # + the notifies above means this only fires when something changed.
  exec { 'webdav-cgi: restart apache':
    command     => 'systemctl restart apache2',
    path        => ['/usr/sbin', '/usr/bin', '/sbin', '/bin'],
    refreshonly => true,
  }
}
