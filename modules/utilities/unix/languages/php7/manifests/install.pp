# == Class: php7::install
#
# Installs PHP 7.4 from the deb.sury.org third-party apt repository and makes
# it the default `php` CLI binary.

class php7::install {

  Exec { path => ['/bin', '/usr/bin', '/usr/local/bin', '/sbin', '/usr/sbin'] }

  ensure_packages(['ca-certificates', 'apt-transport-https', 'lsb-release', 'wget'], { ensure => 'latest' })

  # deb.sury.org (Ondrej Sury's PHP PPA-equivalent for Debian/Ubuntu) ships
  # every still-maintained PHP branch for the current stable release.

  Package['ca-certificates', 'lsb-release', 'wget'] -> Exec['install php7 (sury) apt gpg key']

  exec { 'install php7 (sury) apt gpg key':
    command => '/usr/bin/wget --no-check-certificate -O /etc/apt/trusted.gpg.d/php7-sury.gpg https://packages.sury.org/php/apt.gpg',
    creates => '/etc/apt/trusted.gpg.d/php7-sury.gpg',
  } ->
  exec { 'add php7 (sury) apt repo':
    command => "/bin/echo \"deb ${secgen_functions::mirror_url('https://packages.sury.org/php/')} $(lsb_release -sc) main\" > /etc/apt/sources.list.d/php7-sury.list",
    creates => '/etc/apt/sources.list.d/php7-sury.list',
    provider => shell,  # needs a shell for $(...) and the redirect
  } ->
  exec { 'apt update for php7 (sury) repo':
    command => '/usr/bin/apt-get update',
  } ->
  package { [
    'php7.4',
    'php7.4-cli',
    'php7.4-common',
    'php7.4-mbstring',
    'php7.4-curl',
    'php7.4-xml',
    'php7.4-zip',
    'php7.4-gd',
    'libapache2-mod-php7.4',
  ]:
    ensure => installed,
  } ->

  exec { 'make php7.4 the default php CLI (update-alternatives)':
    command => '/usr/bin/update-alternatives --set php /usr/bin/php7.4',
    unless  => '/usr/bin/test "$(readlink -f /usr/bin/php)" = "/usr/bin/php7.4"',
    provider => shell,  # needs a shell for $(...)
  }
}
