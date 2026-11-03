class samba_symlink_traversal::install {
  include samba

  # smbclient lets an attacker (or this module's own test) enumerate the
  # share anonymously from the command line.
  ensure_packages(['smbclient'])

  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $storage_directory = $secgen_parameters['storage_directory'][0]
  $leaked_filenames = $secgen_parameters['leaked_filenames']
  $strings_to_leak = $secgen_parameters['strings_to_leak']
  $images_to_leak = $secgen_parameters['images_to_leak']
  $strings_to_pre_leak = $secgen_parameters['strings_to_pre_leak']
  $pre_leaked_filenames = $secgen_parameters['pre_leaked_filenames']
  $symlink_traversal = true

  # Ensure the storage directory exists
  file { $storage_directory:
    ensure => directory,
    mode   => '777',
  }

  # Add store to .conf
  file { '/etc/samba/smb_symlink.conf':
    ensure  => file,
    content => template('samba/smb_share.conf.erb'),
    notify  => Exec['concat_samba_conf_and_public_share']
  }

  # Append the public share
  exec { 'concat_samba_conf_and_public_share':
    command => "/bin/bash -c 'cat /etc/samba/smb_symlink.conf >> /etc/samba/smb.conf'"
  }

  # Insert the 'allow insecure wide links = yes' line into the [global] section of smb.conf
  exec { 'sed-insert-global-allow-insecure-wide-links':
    command => "/bin/sed -i \'/\\[global\\]/a allow insecure wide links = yes\' /etc/samba/smb.conf"
  }

  # Leak a flag/string to root directory
  ::secgen_functions::leak_files { 'samba_symlink_traversal-file-leak-2':
    storage_directory => '/',
    leaked_filenames  => $pre_leaked_filenames,
    strings_to_leak   => $strings_to_pre_leak,
    leaked_from       => 'samba_symlink_traversal',
  }

  # Leak a flag/string to the samba share directory
  ::secgen_functions::leak_files { 'samba_symlink_traversal-file-leak-1':
    storage_directory => $storage_directory,
    leaked_filenames  => $leaked_filenames,
    strings_to_leak   => $strings_to_leak,
    images_to_leak    => $images_to_leak,
    leaked_from       => 'samba_symlink_traversal',
    mode              => '0664'
  }
}
