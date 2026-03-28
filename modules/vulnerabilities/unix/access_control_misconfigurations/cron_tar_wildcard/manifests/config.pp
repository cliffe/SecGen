class cron_tar_wildcard::config {
  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $leaked_filenames = $secgen_parameters['leaked_filenames']
  $strings_to_leak = $secgen_parameters['strings_to_leak']

  file { '/var/spool/backups':
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  file { '/opt/backup':
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0777',
  }

  file { '/opt/backup.txt':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => "# cron backup hint\n(cd /opt/backup && tar -zcf /var/spool/backups/backup.tar.gz *)\n",
  }

  cron { 'backup_wildcard':
    command => 'cd /opt/backup && tar -zcf /var/spool/backups/backup.tar.gz *',
    user    => 'root',
    hour    => '*',
    minute  => '*',
  }

  ::secgen_functions::leak_files { 'cron_tar_wildcard-file-leak':
    storage_directory => '/root',
    leaked_filenames  => $leaked_filenames,
    strings_to_leak   => $strings_to_leak,
    owner             => 'root',
    mode              => '0600',
    leaked_from       => 'cron_tar_wildcard',
  }
}
