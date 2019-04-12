class apache::mod::geoip (
  $enable                     = false,
  $db_file                    = '/usr/share/GeoIP/GeoIP.dat',
  $flag                       = 'Standard',
  $output                     = 'All',
  $enable_utf8                = undef,
  $scan_proxy_headers         = undef,
  $scan_proxy_header_field    = undef,
  $use_last_xforwarededfor_ip = undef,
) {
  include ::apache
  ::apache::mod { 'geoip': }

  # Template uses:
  # - enable
  # - db_file
  # - flag
  # - output
  # - enable_utf8
  # - scan_proxy_headers
  # - scan_proxy_header_field
  # - use_last_xforwarededfor_ip
  file { 'geoip.conf':
    ensure  => file,
    path    => "${::apache::mod_dir}/geoip.conf",
    mode    => $::apache::file_mode,
    content => template('apache/mod/geoip.conf.erb'),
    require => Exec["mkdir ${::apache::mod_dir}"],
    before  => File[$::apache::mod_dir],
    notify  => Class['apache::service'],
  }

}
