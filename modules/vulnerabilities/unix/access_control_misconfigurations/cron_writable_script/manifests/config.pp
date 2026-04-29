class cron_writable_script::config {
  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $leaked_filenames = $secgen_parameters['leaked_filenames']
  $strings_to_leak = $secgen_parameters['strings_to_leak']
  $cron_location = $secgen_parameters['cron_location'] ? {
    undef   => '/opt',
    default => $secgen_parameters['cron_location'],
  }
  $cron_message = $secgen_parameters['cron_message'] ? {
    undef   => 'hello from cron',
    default => $secgen_parameters['cron_message'],
  }

  $cron_script_path = "${cron_location}/cron.sh"

  file { $cron_script_path:
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0777',
    content => "#!/bin/bash -p\necho '${cron_message}' >> /tmp/cron.log\n",
  }

  cron { 'writable_cron_script':
    command => $cron_script_path,
    user    => 'root',
    hour    => '*',
    minute  => '*',
    require => File[$cron_script_path],
  }

  ::secgen_functions::leak_files { 'cron_writable_script-file-leak':
    storage_directory => '/root',
    leaked_filenames  => $leaked_filenames,
    strings_to_leak   => $strings_to_leak,
    owner             => 'root',
    mode              => '0600',
    leaked_from       => 'cron_writable_script',
  }
}
