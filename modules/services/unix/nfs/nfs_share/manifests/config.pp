class nfs_share::config {
  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $storage_directory = $secgen_parameters['storage_directory'][0]

  package { ['nfs-kernel-server', 'nfs-common', 'rpcbind']:
      ensure => installed
  }

  group { 'wheel':
    ensure => present,
  }

  file { $storage_directory:
    ensure => 'directory',
    owner  => 'root',
    group  => 'wheel',
    mode   => '0754',
  }

  # Puppet adds the x bit wherever r is set on a directory, so the file
  # resource above ends up 0755. Force the intended 0754 afterwards.
  exec { 'nfs_share_storage_mode':
    command => "chmod 0754 ${storage_directory}",
    path    => ['/usr/bin', '/bin'],
    unless  => "test \"$(stat -c %a ${storage_directory})\" = 754",
    require => File[$storage_directory],
    before  => Service['nfs-kernel-server'],
  }

  file { '/etc/exports':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => [Package['nfs-kernel-server'], File[$storage_directory]],
    content => template('nfs_share/exports.erb'),
  }

  # nfs-server.service has ConditionPathExists=/etc/exports, so it does not
  # start when the package is installed; start it once the exports exist.
  service { 'nfs-kernel-server':
    ensure    => running,
    enable    => true,
    require   => [Package['nfs-kernel-server', 'rpcbind'], File['/etc/exports']],
    subscribe => File['/etc/exports'],
  }

  exec { 'exportfs':
    command => 'exportfs -ra',
    path    => ['/usr/sbin', '/sbin', '/usr/bin', '/bin'],
    require => Service['nfs-kernel-server'],
  }
}
