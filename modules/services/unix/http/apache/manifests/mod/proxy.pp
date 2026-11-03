class apache::mod::proxy (
  $proxy_requests = 'Off',
  $allow_from     = undef,
  $apache_version = undef,
  $package_name   = undef,
  $proxy_via      = 'On',
) {
  include ::apache
  $_apache_version = pick($apache_version, $apache::apache_version)
  ::apache::mod { 'proxy':
    package => $package_name,
  }
  # Template uses $proxy_requests, $_apache_version
  file { 'proxy.conf':
    ensure  => file,
    path    => "${::apache::mod_dir}/proxy.conf",
    mode    => $::apache::file_mode,
    content => template('apache/mod/proxy.conf.erb'),
    require => Exec["mkdir ${::apache::mod_dir}"],
    before  => File[$::apache::mod_dir],
    notify  => Class['apache::service'],
  }
}
