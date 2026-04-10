# Class: raspap_cmd_injection::install
# Install RaspAP v2.8.7 and all required dependencies
# All packages are available in Debian 12 standard repositories
class raspap_cmd_injection::install {
  Exec { path => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ] }
  $user = 'www-data'
  $install_dir = '/var/www/raspap'
  $user_home = '/var/www'

  # Install required packages (all available in Debian 12)
  ensure_packages([
    'lighttpd',
    'php-cgi',
    'php-curl',
    'php-json',
    'php-mbstring',
    'php-xml',
    'php-sqlite3',
    'hostapd',
    'dnsmasq',
    'unzip'
  ])

  # Enable PHP in lighttpd
  exec { 'enable-php-fastcgi':
    command => 'lighttpd-enable-mod fastcgi-php',
    require => Package['lighttpd', 'php-cgi'],
  }

  # Create installation directory
  file { $install_dir:
    ensure => directory,
    owner  => $user,
    group  => $user,
    mode   => '0755',
    require => Package['lighttpd'],
  }

  # Copy RaspAP archive to the system
  # Note: File is named with capital AP but is actually a ZIP archive
  file { "${user_home}/raspAP-webgui-2.8.7.tar.gz":
    source => 'puppet:///modules/raspap_cmd_injection/raspAP-webgui-2.8.7.tar.gz',
    owner  => $user,
    mode   => '0644',
    require => Package['lighttpd'],
  }

  # Extract RaspAP archive (it's a ZIP file despite the .tar.gz extension)
  # Note: GitHub archives extract to raspap-webgui-2.8.7 (with version number)
  -> exec { 'extract-raspap':
    cwd     => $user_home,
    command => 'unzip -o raspAP-webgui-2.8.7.tar.gz',
    creates => "${user_home}/raspap-webgui-2.8.7",
    require => Package['unzip'],
  }

  # Move RaspAP files to installation directory
  -> exec { 'move-raspap':
    cwd     => $user_home,
    command => "mv raspap-webgui-2.8.7/* ${install_dir}/",
    creates => "${install_dir}/index.php",
  }

  # Set proper ownership
  -> exec { 'set-raspap-permissions':
    command => "chown -R ${user}:${user} ${install_dir}",
  }

  # Create necessary directories
  -> exec { 'create-raspap-dirs':
    command => "mkdir -p ${install_dir}/config ${install_dir}/tmp",
  }

  # Set permissions on config and tmp directories
  -> exec { 'set-raspap-dir-permissions':
    command => "chown ${user}:${user} ${install_dir}/config ${install_dir}/tmp",
  }
}
