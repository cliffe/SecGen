# == Class: php7_vulnerable::install
#
# Builds PHP 7.4 from the source tarball bundled in this module (php-src at the
# commit before the php2shell fix) and makes it the default `php`. The source
# is bundled, not downloaded, so the build never picks up a fixed package or
# depends on upstream availability.
#
# The built source tree is left in place: the build reports the same version as
# the patched build, so a check tells vulnerable from patched only by the source
# (the fix adds symbols that this pre-fix tree lacks) and by the commit marker.

class php7_vulnerable::install {

  Exec { path => ['/bin', '/usr/bin', '/usr/local/bin', '/sbin', '/usr/sbin'] }

  # The bundled tarball is the github archive of this commit, which extracts to
  # php-src-<commit>/.
  $vuln_commit = '004cb827501d1ddaf98daacb185a53e0816f78a7'
  $src_tarball = '/opt/php-src-vuln.tar.gz'
  $src_dir     = "/opt/php-src-${vuln_commit}"
  $prefix      = '/opt/php-7.4-vulnerable'
  $php_bin     = "${prefix}/bin/php"

  ensure_packages([
    'build-essential', 'autoconf', 'automake', 'libtool', 'bison', 're2c',
    'pkg-config',
    'libxml2-dev', 'libssl-dev', 'libcurl4-openssl-dev', 'libonig-dev',
    'libzip-dev', 'libpng-dev', 'libjpeg-dev', 'libfreetype6-dev',
    'libsqlite3-dev', 'libicu-dev', 'libreadline-dev', 'zlib1g-dev',
  ], { ensure => 'installed' })

  file { $src_tarball:
    ensure => file,
    source => 'puppet:///modules/php7_vulnerable/php-src-vuln.tar.gz',
  }
  -> exec { 'extract vulnerable php7 source':
    command => "/bin/tar -xzf ${src_tarball} -C /opt",
    creates => $src_dir,
    timeout => 0,
  }
  -> exec { 'buildconf vulnerable php7':
    command => '/bin/sh ./buildconf --force',
    cwd     => $src_dir,
    creates => "${src_dir}/configure",
    timeout => 0,
  }
  -> exec { 'configure vulnerable php7':
    command => "${src_dir}/configure --prefix=${prefix} --enable-cli --enable-fpm \
--with-openssl --with-zlib --with-curl --enable-mbstring --with-libxml \
--enable-gd --with-jpeg --with-freetype --with-zip --enable-intl \
--with-mysqli --enable-pdo --with-pdo-mysql --with-pdo-sqlite --with-readline \
--enable-sockets --enable-session",
    cwd     => $src_dir,
    creates => "${src_dir}/Makefile",
    timeout => 0,
  }
  -> exec { 'make vulnerable php7':
    command => "/usr/bin/make -j${::processorcount}",
    cwd     => $src_dir,
    creates => "${src_dir}/sapi/cli/php",
    timeout => 0,
  }
  -> exec { 'make install vulnerable php7':
    command => '/usr/bin/make install',
    cwd     => $src_dir,
    creates => $php_bin,
    timeout => 0,
  }
  # Provenance marker: the source commit this build came from.
  -> file { "${prefix}/PHP2SHELL_VULN_COMMIT":
    ensure  => file,
    content => "${vuln_commit}\n",
    mode    => '0644',
  }
  -> exec { 'register vulnerable php7 alternative':
    command => "/usr/bin/update-alternatives --install /usr/bin/php php ${php_bin} 99",
    unless  => "/usr/bin/update-alternatives --query php | grep -qx 'Value: ${php_bin}'",
  }
  -> exec { 'make vulnerable php7 the default php CLI':
    command => "/usr/bin/update-alternatives --set php ${php_bin}",
    unless  => "/usr/bin/test \"$(readlink -f /usr/bin/php)\" = \"${php_bin}\"",
  }
}
