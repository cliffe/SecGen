class apache::mod::proxy_connect (
  $apache_version  = undef,
) {
  include ::apache
  $_apache_version = pick($apache_version, $apache::apache_version)
  if versioncmp($_apache_version, '2.2') >= 0 {
    Class['::apache::mod::proxy'] -> Class['::apache::mod::proxy_connect']
    ::apache::mod { 'proxy_connect': }
  }
}
