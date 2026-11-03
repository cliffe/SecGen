# == Class: php7_patched::install
#
# Builds PHP 7.4 from the upstream php-src branch that carries the php2shell
# backport (CVE-2026-109618 / CVE-2026-109619) and makes it the default `php`.
#
# The 7.4 branch is end of life, so there is no released 7.4 package with the
# fix: upstream published the fix only as a source branch for 7.4. The build is
# pinned to a single commit so it is reproducible, and the commit is written to
# a provenance marker because the built interpreter reports 7.4.31-dev and the
# fix cannot be told from the version string.

class php7_patched::install {

  Exec { path => ['/bin', '/usr/bin', '/usr/local/bin', '/sbin', '/usr/sbin'] }

  # Pinned source: php-src branch PHP-7.4-CVE-2026-109618-109619.
  $fix_commit  = '712e60f9edfd03f0960fc4fc3c2c375f42b90aa2'
  $src_tarball = "/opt/php-src-${fix_commit}.tar.gz"
  $src_dir     = "/opt/php-src-${fix_commit}"
  $prefix      = '/opt/php-7.4-patched'
  $php_bin     = "${prefix}/bin/php"
  $archive_url = "https://github.com/php/php-src/archive/${fix_commit}.tar.gz"

  # Toolchain plus the -dev libraries for the extensions the build enables.
  ensure_packages([
    'build-essential', 'autoconf', 'automake', 'libtool', 'bison', 're2c',
    'pkg-config', 'ca-certificates', 'wget',
    'libxml2-dev', 'libssl-dev', 'libcurl4-openssl-dev', 'libonig-dev',
    'libzip-dev', 'libpng-dev', 'libjpeg-dev', 'libfreetype6-dev',
    'libsqlite3-dev', 'libicu-dev', 'libreadline-dev', 'zlib1g-dev',
  ], { ensure => 'installed' })

  exec { 'download patched php7 source':
    command => "/usr/bin/wget -O ${src_tarball} ${archive_url}",
    creates => $src_tarball,
    timeout => 0,
    require => Package['wget'],
  } ->
  exec { 'extract patched php7 source':
    command => "/bin/tar -xzf ${src_tarball} -C /opt",
    creates => $src_dir,
    timeout => 0,
  } ->
  # 7.4's buildconf predates the autoconf on bookworm; --force lets it proceed.
  exec { 'buildconf patched php7':
    command => '/bin/sh ./buildconf --force',
    cwd     => $src_dir,
    creates => "${src_dir}/configure",
    timeout => 0,
  } ->
  exec { 'configure patched php7':
    command => "${src_dir}/configure --prefix=${prefix} --enable-cli --enable-fpm \
--with-openssl --with-zlib --with-curl --enable-mbstring --with-libxml \
--enable-gd --with-jpeg --with-freetype --with-zip --enable-intl \
--with-mysqli --enable-pdo --with-pdo-mysql --with-pdo-sqlite --with-readline \
--enable-sockets --enable-session",
    cwd     => $src_dir,
    creates => "${src_dir}/Makefile",
    timeout => 0,
  } ->
  exec { 'make patched php7':
    command => "/usr/bin/make -j${::processorcount}",
    cwd     => $src_dir,
    creates => "${src_dir}/sapi/cli/php",
    timeout => 0,
  } ->
  exec { 'make install patched php7':
    command => '/usr/bin/make install',
    cwd     => $src_dir,
    creates => $php_bin,
    timeout => 0,
  } ->
  # Provenance marker: the fix is identified by source commit, not version.
  file { "${prefix}/PHP2SHELL_FIX_COMMIT":
    ensure  => file,
    content => "${fix_commit}\n",
    mode    => '0644',
  } ->
  # Make the patched build the default `php` CLI.
  exec { 'register patched php7 alternative':
    command => "/usr/bin/update-alternatives --install /usr/bin/php php ${php_bin} 99",
    unless  => "/usr/bin/update-alternatives --query php | grep -qx 'Value: ${php_bin}'",
  } ->
  exec { 'make patched php7 the default php CLI':
    command => "/usr/bin/update-alternatives --set php ${php_bin}",
    unless  => "/usr/bin/test \"$(readlink -f /usr/bin/php)\" = \"${php_bin}\"",
  }

  # Run php-fpm on 127.0.0.1:9000 so an Apache/lighttpd app can reach the patched
  # interpreter over FastCGI without each app configuring a pool itself.
  file { "${prefix}/etc/php-fpm.conf":
    ensure  => file,
    mode    => '0644',
    content => "[global]\npid = /run/php7-patched-fpm.pid\nerror_log = /var/log/php7-patched-fpm.log\ninclude=${prefix}/etc/php-fpm.d/*.conf\n",
    require => Exec['make install patched php7'],
  }
  file { "${prefix}/etc/php-fpm.d/www.conf":
    ensure  => file,
    mode    => '0644',
    content => "[www]\nuser = www-data\ngroup = www-data\nlisten = 127.0.0.1:9000\npm = dynamic\npm.max_children = 5\npm.start_servers = 2\npm.min_spare_servers = 1\npm.max_spare_servers = 3\n",
    require => Exec['make install patched php7'],
  }
  -> file { '/etc/systemd/system/php7-patched-fpm.service':
    ensure  => file,
    mode    => '0644',
    content => "[Unit]\nDescription=php7_patched php-fpm\nAfter=network.target\n\n[Service]\nExecStart=${prefix}/sbin/php-fpm --nodaemonize --fpm-config ${prefix}/etc/php-fpm.conf\nRestart=always\n\n[Install]\nWantedBy=multi-user.target\n",
    require => File["${prefix}/etc/php-fpm.conf"],
  }
  ~> exec { 'php7-patched-fpm daemon-reload':
    command     => '/bin/systemctl daemon-reload',
    path        => ['/bin', '/usr/bin', '/sbin', '/usr/sbin'],
    refreshonly => true,
  }
  -> service { 'php7-patched-fpm':
    ensure => running,
    enable => true,
  }
}
