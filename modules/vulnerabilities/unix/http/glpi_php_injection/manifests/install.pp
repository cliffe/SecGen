# Class: glpi_php_injection::install
# Installs GLPI 9.5.8 and PHP 7.4.
# https://github.com/glpi-project/glpi/releases/tag/9.5.8
class glpi_php_injection::install {
  Exec { path => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ] }

  ensure_packages(['mariadb-server'], { ensure => 'installed' })

  # GLPI 9.5.8's db:install corrupts its own bundled SQL schema under PHP 8.2
  # (quoted column defaults go missing, producing a MariaDB syntax error on the
  # first CREATE TABLE), so it needs PHP 7.4 instead.  Installed from
  # deb.sury.org rather than via the shared php7 utility module: php7's
  # secgen_metadata.xml carries a <conflict><type>webapp</type>, which this
  # module also declares, so requiring it would make this module unselectable.
  # Apache's PHP module is enabled in apache.pp once apache2 is installed.
  # The system's PHP 8.2 is still present (installed and patched by the
  # required php82_patched utility) — only the CLI default and Apache's
  # active module are switched to 7.4 for GLPI's benefit.
  ensure_packages(['ca-certificates', 'apt-transport-https', 'lsb-release'], { ensure => 'latest' })

  exec { 'install php7 (sury) apt gpg key':
    command => '/usr/bin/wget --no-check-certificate -O /etc/apt/trusted.gpg.d/php7-sury.gpg https://packages.sury.org/php/apt.gpg',
    creates => '/etc/apt/trusted.gpg.d/php7-sury.gpg',
  }
  -> exec { 'add php7 (sury) apt repo':
    command => "/bin/echo \"deb ${secgen_functions::mirror_url('https://packages.sury.org/php/')} $(lsb_release -sc) main\" > /etc/apt/sources.list.d/php7-sury.list",
    creates => '/etc/apt/sources.list.d/php7-sury.list',
  }
  -> exec { 'apt update for php7 (sury) repo':
    command => '/usr/bin/apt-get update',
  }
  -> package { [
    'php7.4',
    'php7.4-cli',
    'php7.4-common',
    'php7.4-curl',
    'php7.4-gd',
    'php7.4-intl',
    'php7.4-mysql',
    'php7.4-mbstring',
    'php7.4-xml',
    'php7.4-ldap',
    'php7.4-apcu',
    'php7.4-zip',
    'php7.4-bz2',
    'libapache2-mod-php7.4',
  ]:
    ensure => installed,
  }
  -> exec { 'make php7.4 the default php CLI (update-alternatives)':
    command => '/usr/bin/update-alternatives --set php /usr/bin/php7.4',
    unless  => '/usr/bin/test "$(readlink -f /usr/bin/php)" = "/usr/bin/php7.4"',
  }

  $releasename = 'glpi-9.5.8.tgz'
  file { "/tmp/${releasename}":
    ensure => file,
    source => "puppet:///modules/glpi_php_injection/${releasename}",
  }
  -> exec { 'extract-glpi':
    cwd     => '/tmp',
    command => "tar -xf ${releasename}",
    creates => '/tmp/glpi'
  }
  -> exec { 'move-glpi':
    cwd     => '/tmp',
    command => 'mv glpi/ /var/www/html',
    creates => '/var/www/html/glpi/',
  }
  -> exec { 'chmod-glpi':
    command => 'chmod 755 -R /var/www/html/glpi/',
  }
  -> exec { 'chown-glpi':
    command => 'chown www-data:www-data -R /var/www/html/glpi/',
  }

}
