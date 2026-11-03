class samba_public_writable_share::install {
  include samba

  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $storage_directory = $secgen_parameters['storage_directory'][0]
  $leaked_filenames = $secgen_parameters['leaked_filenames']
  $strings_to_leak = $secgen_parameters['strings_to_leak']
  $images_to_leak = $secgen_parameters['images_to_leak']

  # Ensure the storage directory exists. It must be world-writable so the Samba
  # guest account (nobody) can create files in the share: without this the share
  # is listable anonymously but every write is refused with NT_STATUS_ACCESS_DENIED.
  # A world-writable public directory is the misconfiguration this module models.
  file { $storage_directory:
    ensure => directory,
    mode   => '0777',
  }

  # Add store to .conf
  file { '/etc/samba/smb_pws.conf':
    ensure  => file,
    content => template('samba/smb_share.conf.erb'),
    notify  => Exec['concat_samba_conf_and_public_share']
  }

  # Append the public share
  exec { 'concat_samba_conf_and_public_share':
    command => "/bin/bash -c 'cat /etc/samba/smb_pws.conf >> /etc/samba/smb.conf'"
  }

  ::secgen_functions::leak_files { 'samba_public_writable_share-file-leak':
    storage_directory => $storage_directory,
    leaked_filenames  => $leaked_filenames,
    strings_to_leak   => $strings_to_leak,
    images_to_leak    => $images_to_leak,
    leaked_from       => 'samba_public_writable_share',
    mode              => '0666'
  }
}