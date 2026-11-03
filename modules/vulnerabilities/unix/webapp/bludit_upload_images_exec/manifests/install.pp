class bludit_upload_images_exec::install {
  Exec { path => ['/bin', '/usr/bin', '/usr/local/bin', '/sbin', '/usr/sbin'] }

  # php7_patched compiles with --enable-gd --enable-mbstring --with-libxml
  # --with-zip so Bludit's required extensions are already present. No apt PHP
  # extension packages needed.

  $releasename = 'bludit-3-9-2'

  file { '/var/www':
    ensure => directory,
    mode   => '0755',
  }

  file { "/usr/local/src/${releasename}.zip":
    ensure => file,
    source => "puppet:///modules/bludit_upload_images_exec/${releasename}.zip",
  }
  -> exec { 'unpack-bludit':
    cwd     => '/usr/local/src',
    command => "unzip ${releasename}.zip -d /var/www",
    creates => "/var/www/${releasename}",
    require => File['/var/www'],
  }
  -> exec { 'chown-bludit':
    command => 'chown www-data. /var/www -R',
  }
}
