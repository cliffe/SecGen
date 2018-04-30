class apache::mod::cluster (
  $allowed_network,
  $balancer_name,
  $ip,
  $version,
  $enable_mcpm_receive = true,
  $port = '6666',
  $keep_alive_timeout = 60,
  $manager_allowed_network = '127.0.0.1',
  $max_keep_alive_requests = 0,
  $server_advertise = true,
) {

  include ::apache

  ::apache::mod { 'proxy': }
  ::apache::mod { 'proxy_ajp': }
  ::apache::mod { 'manager': }
  ::apache::mod { 'proxy_cluster': }
  ::apache::mod { 'advertise': }

  if (versioncmp($version, '1.3.0') >= 0 ) {
    ::apache::mod { 'cluster_slotmem': }
  } else {
    ::apache::mod { 'slotmem': }
  }

  file {'cluster.conf':
    ensure  => file,
    path    => "${::apache::mod_dir}/cluster.conf",
    mode    => $::apache::file_mode,
    content => template('apache/mod/cluster.conf.erb'),
    require => Exec["mkdir ${::apache::mod_dir}"],
    before  => File[$::apache::mod_dir],
    notify  => Class['apache::service'],
  }

}
