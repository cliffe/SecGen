class cron_tar_wildcard::config {
  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $leaked_filenames = $secgen_parameters['leaked_filenames']
  $strings_to_leak = $secgen_parameters['strings_to_leak']
  $show_crontab_hint = $secgen_parameters['show_crontab_hint']
  $cron_location = $secgen_parameters['cron_location'] ? {
    undef   => '/opt',
    default => $secgen_parameters['cron_location'],
  }

  $backup_dir = "${cron_location}/backup"

  package { 'cron':
    ensure => installed,
  }

  service { 'cron':
    ensure  => running,
    enable  => true,
    require => Package['cron'],
  }

  file { '/var/spool/backups':
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  file { $backup_dir:
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0777',
  }

  if $show_crontab_hint =~ /^(true|1|yes)$/ {
    # Enable sudo access to crontab -l so players can discover the cron job
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
      content => "# cron backup hint\n# Try: sudo -l to see what you can run\n# Then: sudo crontab -l to view root's cron jobs\n(cd ${backup_dir} && tar -zcf /var/spool/backups/backup.tar.gz *)\n",
    }
  } else {
    file { "${cron_location}/backup.txt":
      ensure  => file,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => "# cron backup hint\n(cd ${backup_dir} && tar -zcf /var/spool/backups/backup.tar.gz *)\n",
    }
  }

  cron { 'backup_wildcard':
    command => "cd ${backup_dir} && tar -zcf /var/spool/backups/backup.tar.gz *",
    user    => 'root',
    hour    => '*',
    minute  => '*',
    require => [Service['cron'], File[$backup_dir]],
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
