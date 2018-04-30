class nfs_overshare::config {

  # Setup SecGen Parameters
  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $leaked_filenames=$secgen_parameters['leaked_filenames']
  $strings_to_leak=$secgen_parameters['strings_to_leak']
  $images_to_leak=$secgen_parameters['images_to_leak']
  $storage_directory=$secgen_parameters['storage_directory'][0]

  package { ['nfs-kernel-server', 'nfs-common', 'portmap']:
    ensure => installed
  }


  file { '/etc/exports':
    require => Package['nfs-common'],
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0777',
    content  => template('nfs_overshare/exports.erb')
  }

  file { $storage_directory:
    require => Package['nfs-common'],
    ensure => 'directory',
    owner   => 'root',
    group   => 'root'
  }

  exec { "exportfs":
    require => Package['nfs-common'],
    command => "exportfs -a",
    path    => "/usr/sbin",
    # path    => [ "/usr/local/bin/", "/bin/" ],  # alternative syntax
  }

  ::secgen_functions::leak_files { 'nfs_overshare-file-leak':
    storage_directory => $storage_directory,
    leaked_filenames => $leaked_filenames,
    strings_to_leak => $strings_to_leak,
    images_to_leak => $images_to_leak,
    leaked_from => "nfs_overshare",
  }
}
