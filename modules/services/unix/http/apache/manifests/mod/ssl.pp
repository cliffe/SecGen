class apache::mod::ssl (
  Boolean $ssl_compression                                  = false,
  $ssl_cryptodevice                                         = 'builtin',
  $ssl_options                                              = [ 'StdEnvVars' ],
  $ssl_openssl_conf_cmd                                     = undef,
  $ssl_ca                                                   = undef,
  $ssl_cipher                                               = 'HIGH:MEDIUM:!aNULL:!MD5:!RC4:!3DES',
  Variant[Boolean, Enum['on', 'off']] $ssl_honorcipherorder = true,
  $ssl_protocol                                             = [ 'all', '-SSLv2', '-SSLv3' ],
  Array $ssl_proxy_protocol                                 = [],
  $ssl_pass_phrase_dialog                                   = 'builtin',
  $ssl_random_seed_bytes                                    = '512',
  String $ssl_sessioncache                                  = $::apache::params::ssl_sessioncache,
  $ssl_sessioncachetimeout                                  = '300',
  Boolean $ssl_stapling                                     = false,
  Optional[Boolean] $ssl_stapling_return_errors             = undef,
  $ssl_mutex                                                = undef,
  $apache_version                                           = undef,
  $package_name                                             = undef,
) inherits ::apache::params {

  include ::apache
  include ::apache::mod::mime
  $_apache_version = pick($apache_version, $apache::apache_version)
  if $ssl_mutex {
    $_ssl_mutex = $ssl_mutex
  } else {
    case $::osfamily {
      'debian': {
        if versioncmp($_apache_version, '2.4') >= 0 {
          $_ssl_mutex = 'default'
        } elsif $::operatingsystem == 'Ubuntu' and $::operatingsystemrelease == '10.04' {
          $_ssl_mutex = 'file:/var/run/apache2/ssl_mutex'
        } else {
          $_ssl_mutex = "file:\${APACHE_RUN_DIR}/ssl_mutex"
        }
      }
      'redhat': {
        $_ssl_mutex = 'default'
      }
      'freebsd': {
        $_ssl_mutex = 'default'
      }
      'gentoo': {
        $_ssl_mutex = 'default'
      }
      'Suse': {
        $_ssl_mutex = 'default'
      }
      default: {
        fail("Unsupported osfamily ${::osfamily}, please explicitly pass in \$ssl_mutex")
      }
    }
  }

  if is_bool($ssl_honorcipherorder) {
    $_ssl_honorcipherorder = $ssl_honorcipherorder
  } else {
    $_ssl_honorcipherorder = $ssl_honorcipherorder ? {
      'on'    => true,
      'off'   => false,
      default => true,
    }
  }

  $stapling_cache = $::osfamily ? {
    'debian'  => "\${APACHE_RUN_DIR}/ocsp(32768)",
    'redhat'  => '/run/httpd/ssl_stapling(32768)',
    'freebsd' => '/var/run/ssl_stapling(32768)',
    'gentoo'  => '/var/run/ssl_stapling(32768)',
    'Suse'    => '/var/lib/apache2/ssl_stapling(32768)',
  }

  if $::osfamily == 'Suse' {
    if defined(Class['::apache::mod::worker']){
      $suse_path = '/usr/lib64/apache2-worker'
    } else {
      $suse_path = '/usr/lib64/apache2-worker'
    }
    ::apache::mod { 'ssl':
      package  => $package_name,
      lib_path => $suse_path,
    }
  } else {
    ::apache::mod { 'ssl':
      package => $package_name,
    }
  }

  if versioncmp($_apache_version, '2.4') >= 0 {
    include ::apache::mod::socache_shmcb
  }

  # Template uses
  #
  # $ssl_compression
  # $ssl_cryptodevice
  # $ssl_ca
  # $ssl_cipher
  # $ssl_honorcipherorder
  # $ssl_options
  # $ssl_openssl_conf_cmd
  # $ssl_sessioncache
  # $stapling_cache
  # $ssl_mutex
  # $ssl_random_seed_bytes
  # $ssl_sessioncachetimeout
  # $_apache_version
  file { 'ssl.conf':
    ensure  => file,
    path    => $::apache::_ssl_file,
    mode    => $::apache::file_mode,
    content => template('apache/mod/ssl.conf.erb'),
    require => Exec["mkdir ${::apache::mod_dir}"],
    before  => File[$::apache::mod_dir],
    notify  => Class['apache::service'],
  }
}
