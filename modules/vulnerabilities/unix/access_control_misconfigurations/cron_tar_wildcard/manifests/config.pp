class cron_tar_wildcard::config {
  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $leaked_filenames = $secgen_parameters['leaked_filenames']
  $strings_to_leak = $secgen_parameters['strings_to_leak']
  $show_crontab_hint = $secgen_parameters['show_crontab_hint']
  $cron_location = $secgen_parameters['cron_location'] ? {
    undef   => '/opt',
    default => $secgen_parameters['cron_location'],
  }
  $cron_user = $secgen_parameters['cron_user'] ? {
    undef   => 'root',
    default => $secgen_parameters['cron_user'],
  }
  $restrict_write_user_input = $secgen_parameters['restrict_write_user']

  $backup_dir = "${cron_location}/backup"
  $archive_dest = '/var/spool/backups'

  $leak_storage_dir = $cron_user ? {
    'root'  => '/root',
    default => "/home/${cron_user}",
  }

  package { 'cron':
    ensure => installed,
  }

  service { 'cron':
    ensure  => running,
    enable  => true,
    require => Package['cron'],
  }

  if $restrict_write_user_input and $restrict_write_user_input != '' {
    $restrict_write_user = $restrict_write_user_input
    $backup_dir_owner = $restrict_write_user
    $backup_dir_group = $restrict_write_user
    $backup_dir_mode = '0755'
    $archive_owner = $restrict_write_user
    $archive_group = $restrict_write_user
    $archive_mode = '0755'

    exec { "validate_restricted_user":
      command => "/usr/bin/id ${restrict_write_user}",
      unless  => "/usr/bin/id ${restrict_write_user}",
      path    => ['/usr/bin'],
      before  => File[$backup_dir],
    }

    notice("Permission hierarchy: Write access restricted to user '${restrict_write_user}'")
    notice("Backup directory mode: 0755 (user-writable only)")
    notice("Archive directory mode: 0755 (user-writable only)")

    file { $archive_dest:
      ensure  => directory,
      owner   => $archive_owner,
      group   => $archive_group,
      mode    => $archive_mode,
    }

    file { $backup_dir:
      ensure  => directory,
      owner   => $backup_dir_owner,
      group   => $backup_dir_group,
      mode    => $backup_dir_mode,
      require => Exec['validate_restricted_user'],
    }
  } else {
    $backup_dir_owner = 'root'
    $backup_dir_group = 'root'
    $backup_dir_mode = '0777'
    $archive_owner = 'root'
    $archive_group = 'root'
    $archive_mode = '0777'

    notice("Permission hierarchy: Write access global (mode 0777)")
    notice("Backup directory mode: 0777 (world-writable)")
    notice("Archive directory mode: 0777 (world-writable)")

    file { $archive_dest:
      ensure => directory,
      owner  => $archive_owner,
      group  => $archive_group,
      mode   => $archive_mode,
    }

    file { $backup_dir:
      ensure => directory,
      owner  => $backup_dir_owner,
      group  => $backup_dir_group,
      mode   => $backup_dir_mode,
    }
  }

  if $show_crontab_hint =~ /^(true|1|yes)$/ {
    class { 'sudo':
      config_file_replace => false,
    }

    sudo::conf { 'users_sudo_list':
      ensure  => present,
      content => 'ALL  ALL=(root) NOPASSWD: /usr/bin/sudo -l',
    }

    sudo::conf { 'users_crontab_list':
      ensure  => present,
      content => 'ALL  ALL=(root) NOPASSWD: /usr/bin/crontab -l',
    }

    file { "${cron_location}/backup.txt":
      ensure  => file,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => "# cron backup hint\n# Try: sudo -l to see what you can run\n# Then: sudo crontab -l to view root's cron jobs\n(cd ${backup_dir} && tar -zcf ${archive_dest}/backup.tar.gz *)\n",
    }
  } else {
    file { "${cron_location}/backup.txt":
      ensure  => file,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => "# cron backup hint\n(cd ${backup_dir} && tar -zcf ${archive_dest}/backup.tar.gz *)\n",
    }
  }

  cron { 'backup_wildcard':
    command => "cd ${backup_dir} && tar -zcf ${archive_dest}/backup.tar.gz *",
    user    => $cron_user,
    hour    => '*',
    minute  => '*',
    require => [Service['cron'], File[$backup_dir], File[$archive_dest]],
  }

  ::secgen_functions::leak_files { 'cron_tar_wildcard-file-leak':
    storage_directory => $leak_storage_dir,
    leaked_filenames  => $leaked_filenames,
    strings_to_leak   => $strings_to_leak,
    owner             => $cron_user,
    mode              => '0600',
    leaked_from       => 'cron_tar_wildcard',
  }
}