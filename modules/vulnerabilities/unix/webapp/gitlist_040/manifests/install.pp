class gitlist_040::install {

  Exec { path => ['/bin', '/usr/bin', '/usr/local/bin', '/sbin', '/usr/sbin'] }

  ensure_packages('git')

  $archive = 'gitlist-0.4.0.tar.gz'

  # apache2 is installed later (apache.pp); create the web root now.
  file { '/var/www':
    ensure => directory,
    mode   => '0755',
  }

  file { "/usr/local/src/$archive":
    ensure => file,
    source => "puppet:///modules/gitlist_040/$archive",
  }

  exec { 'unpack-gitlist':
    cwd     => '/usr/local/src',
    command => "tar -xzf $archive -C /var/www",
    require => File['/var/www'],
  }

  exec { 'copy-ini-file':
    require => Exec['unpack-gitlist'],
    command => 'cp /var/www/gitlist/config.ini-example /var/www/gitlist/config.ini',
  }

  # Fix PHP 7.2+ incompatibility: Gitter uses 'Object' as a class name, which
  # PHP 7.2+ reserves. Rename it to 'GitObject' across all vendor files and
  # the Composer autoloader classmap; restart php7-patched-fpm to flush OPcache.
  # Without this fix exploit/multi/http/gitlist_arg_injection aborts on the tree
  # enumeration step ("No files found in repos") because the /tree/ endpoint
  # raises a PHP Fatal Error.
  file { '/var/www/gitlist/fix-gitter-php7.sh':
    ensure  => file,
    mode    => '0755',
    source  => 'puppet:///modules/gitlist_040/fix-gitter-php7.sh',
    require => Exec['copy-ini-file'],
  }

  exec { 'fix-gitter-php7-compat':
    command => '/var/www/gitlist/fix-gitter-php7.sh',
    unless  => 'grep -q "class GitObject" /var/www/gitlist/vendor/klaussilveira/gitter/lib/Gitter/Model/Object.php',
    require => File['/var/www/gitlist/fix-gitter-php7.sh'],
  }

  exec { 'restart-php7-patched-fpm-after-php7-fix':
    command     => 'systemctl restart php7-patched-fpm',
    refreshonly => true,
    subscribe   => Exec['fix-gitter-php7-compat'],
  }

  file { '/var/www/gitlist/cache':
    require => Exec['unpack-gitlist'],
    ensure  => directory,
    mode    => '777',
  }

  # GitList routes pretty URLs to index.php via .htaccess (needs mod_rewrite and
  # AllowOverride All, set in apache.pp).
  file { '/var/www/gitlist/.htaccess':
    require => Exec['unpack-gitlist'],
    ensure  => present,
    content => template('gitlist_040/.htaccess.erb'),
  }
}
