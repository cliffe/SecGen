# Serve an unauthenticated, writable WebDAV collection over Apache.
# Enables mod_dav/mod_dav_fs and publishes a vhost whose WebDAV directory is
# owned by the Apache user (so PUT/MKCOL/DELETE succeed) with no Require
# directive beyond the default "all granted" — i.e. no authentication.
class apache_webdav_upload::install {
  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $port        = $secgen_parameters['port'][0]
  $webdav_path = $secgen_parameters['webdav_path'][0]

  $docroot    = '/var/www/webdav'
  $webdav_dir = "${docroot}/${webdav_path}"

  # Declared here rather than relying on the required apache service module:
  # each SecGen module is a separate puppet apply, so this module's catalogue
  # must declare apache itself for apache::mod::dav to resolve.
  class { '::apache':
    default_vhost   => false,
    overwrite_ports => false,
    mpm_module      => 'prefork',
  }

  include apache::mod::dav
  include apache::mod::dav_fs

  file { $docroot:
    ensure => directory,
    owner  => 'www-data',
    group  => 'www-data',
    mode   => '0755',
  }

  # The WebDAV collection the attacker writes into.
  file { $webdav_dir:
    ensure  => directory,
    owner   => 'www-data',
    group   => 'www-data',
    mode    => '0755',
    require => File[$docroot],
  }

  # priority 05 keeps this vhost ahead of any default vhost on the same port.
  # No auth_require/require on the directory: the _require template then emits
  # "Require all granted", leaving the collection open to anyone.
  apache::vhost { 'apache-webdav-upload':
    priority    => '05',
    port        => $port,
    docroot     => $docroot,
    directories => [
      {
        'path'    => $webdav_dir,
        'dav'     => 'On',
        'options' => ['Indexes', 'FollowSymLinks'],
      },
    ],
    require     => File[$webdav_dir],
  }
}
