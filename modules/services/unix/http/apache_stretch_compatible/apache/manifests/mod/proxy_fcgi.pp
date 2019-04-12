class apache::mod::proxy_fcgi {
  Class['::apache::mod::proxy'] -> Class['::apache::mod::proxy_fcgi']
  ::apache::mod { 'proxy_fcgi': }
}
