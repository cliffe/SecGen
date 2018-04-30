class apache::mod::proxy_balancer(
  $manager        = false,
  $manager_path   = '/balancer-manager',
  $allow_from     = ['127.0.0.1','::1'],
  $apache_version = $::apache::apache_version,
) {
  validate_bool($manager)
  validate_string($manager_path)
  validate_array($allow_from)

  include ::apache::mod::proxy
  include ::apache::mod::proxy_http
  if versioncmp($apache_version, '2.4') >= 0 {
    ::apache::mod { 'slotmem_shm': }
  }

  Class['::apache::mod::proxy'] -> Class['::apache::mod::proxy_balancer']
  Class['::apache::mod::proxy_http'] -> Class['::apache::mod::proxy_balancer']
  ::apache::mod { 'proxy_balancer': }
  if $manager {
    include ::apache::mod::status
    file { 'proxy_balancer.conf':
      ensure  => file,
      path    => "${::apache::mod_dir}/proxy_balancer.conf",
      mode    => $::apache::file_mode,
      content => template('apache/mod/proxy_balancer.conf.erb'),
      require => Exec["mkdir ${::apache::mod_dir}"],
      before  => File[$::apache::mod_dir],
      notify  => Class['apache::service'],
    }
  }
}
