class cron_writable_script::config {
  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $leaked_filenames = $secgen_parameters['leaked_filenames']
  $strings_to_leak = $secgen_parameters['strings_to_leak']
  
  # Extract first element from arrays (SecGen generators output arrays)
  $cron_location_raw = $secgen_parameters['cron_location']
  $cron_location = $cron_location_raw ? {
    undef   => '/opt',
    default => $cron_location_raw[0],
  }
  
  $cron_message_raw = $secgen_parameters['cron_message']
  $cron_message = $cron_message_raw ? {
    undef   => 'hello from cron',
    default => $cron_message_raw[0],
  }
  
  $cron_user_raw = $secgen_parameters['cron_user']
  $cron_user = $cron_user_raw ? {
    undef   => 'root',
    default => $cron_user_raw[0],
  }

  # Validate cron_user exists (if not root)
  if $cron_user != 'root' {
    exec { "validate_cron_user_${cron_user}":
      command => "/usr/bin/id ${cron_user}",
      unless  => "/usr/bin/id ${cron_user}",
      path    => ['/usr/bin'],
    }
  }

  $cron_script_path = "${cron_location}/cron.sh"
  $leak_storage_dir = $cron_user ? {
    'root' => '/root',
    default => "/home/${cron_user}",
  }

  file { $cron_script_path:
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0777',
    content => "#!/bin/bash -p\necho '${cron_message}' >> /tmp/cron.log\n",
    require => $cron_user ? {
      'root' => undef,
      default => Exec["validate_cron_user_${cron_user}"],
    },
  }

  cron { 'writable_cron_script':
    command => $cron_script_path,
    user    => $cron_user,
    hour    => '*',
    minute  => '*',
    require => File[$cron_script_path],
  }

  ::secgen_functions::leak_files { 'cron_writable_script-file-leak':
    storage_directory => $leak_storage_dir,
    leaked_filenames  => $leaked_filenames,
    strings_to_leak   => $strings_to_leak,
    owner             => $cron_user,
    mode              => '0600',
    leaked_from       => 'cron_writable_script',
  }
}