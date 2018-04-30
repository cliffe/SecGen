class nfs_rootshare::config {

  # Setup SecGen Parameters
  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)$leaked_filenames=$secgen_parameters['leaked_filenames']
  $strings_to_leak=$secgen_parameters['strings_to_leak']
  $images_to_leak=$secgen_parameters['images_to_leak']

  package { ['nfs-kernel-server', 'nfs-common', 'portmap']:
      ensure => installed
  }

  file { '/etc/exports':
    require => Package['nfs-common'],
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0777',
    content  => template('nfs_rootshare/exports.erb')
  }

  exec { "exportfs":
      require => Package['nfs-common'],
      command => "exportfs -a",
      path    => "/usr/sbin",
      # path    => [ "/usr/local/bin/", "/bin/" ],  # alternative syntax
  }

  ::secgen_functions::leak_files { 'nfs_rootshare-file-leak':
    storage_directory => '/root',
    leaked_filenames => $leaked_filenames,
    strings_to_leak => $strings_to_leak,
    images_to_leak => $images_to_leak,
    leaked_from => "nfs_rootshare",
  }
}


