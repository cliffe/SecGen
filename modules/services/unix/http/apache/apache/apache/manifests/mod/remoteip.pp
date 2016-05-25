class apache::mod::remoteip (
  $header            = 'X-Forwarded-For',
  $proxy_ips         = [ '127.0.0.1' ],
  $proxies_header    = undef,
  $trusted_proxy_ips = undef,
  $apache_version    = $::apache::apache_version
) {
  if versioncmp($apache_version, '2.4') < 0 {
    fail('mod_remoteip is only available in Apache 2.4')
  }

  ::apache::mod { 'remoteip': }

  # Template uses:
  # - $header
  # - $proxy_ips
  # - $proxies_header
  # - $trusted_proxy_ips
  file { 'remoteip.conf':
    ensure  => file,
    path    => "${::apache::mod_dir}/remoteip.conf",
    content => template('apache/mod/remoteip.conf.erb'),
    require => Exec["mkdir ${::apache::mod_dir}"],
    before  => File[$::apache::mod_dir],
    notify  => Service['httpd'],
  }
}
