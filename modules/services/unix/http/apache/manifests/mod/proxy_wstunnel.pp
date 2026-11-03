class apache::mod::proxy_wstunnel {
  include ::apache, ::apache::mod::proxy
  Class['::apache::mod::proxy'] -> Class['::apache::mod::proxy_wstunnel']
  ::apache::mod { 'proxy_wstunnel': }
}
