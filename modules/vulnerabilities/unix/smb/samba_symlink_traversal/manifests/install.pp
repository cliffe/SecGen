class samba_symlink_traversal::install {
  include samba

  $json_inputs = base64('decode', $::base64_inputs)
  $secgen_parameters = parsejson($json_inputs)
  $storage_directory = $secgen_parameters['storage_directory'][0]
  $leaked_filenames = $secgen_parameters['leaked_filenames']
  $strings_to_leak = $secgen_parameters['strings_to_leak']
  $images_to_leak = $secgen_parameters['images_to_leak']
  $symlink_traversal = true

  # Ensure the storage directory exists
  file { $storage_directory:
    ensure => directory,
  }

  # Add store to .conf
  file { '/etc/samba/smb_symlink.conf':
    ensure => file,
    content => template ('samba/smb_share.conf.erb')
  }
  concat { '/etc/samba/smb.conf':
    ensure => present,
  }
  concat::fragment { 'smb-conf-base':
    source => '/etc/samba/smb.conf',
    target => '/etc/samba/smb.conf',
    order => '01',
  }
  concat::fragment { 'smb-conf-public-share-definition':
    source => '/etc/samba/smb_symlink.conf',
    target => '/etc/samba/smb.conf',
    order => '02',
  }

  # Insert the 'allow insecure wide links = yes' line into the [global] section of smb.conf
  exec { 'sed-insert-global-allow-insecure-wide-links':
    command => "/bin/sed -i \'/\\[global\\]/a allow insecure wide links = yes\' /etc/samba/smb.conf"
  }

  ::secgen_functions::leak_files { 'samba_symlink_traversal-file-leak':
    storage_directory => $storage_directory,
    leaked_filenames  => $leaked_filenames,
    strings_to_leak   => $strings_to_leak,
    images_to_leak    => $images_to_leak,
    leaked_from       => 'samba_symlink_traversal',
  }
}