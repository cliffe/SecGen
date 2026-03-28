class cron_writable_script::config {
  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $leaked_filenames = $secgen_parameters['leaked_filenames']
  $strings_to_leak = $secgen_parameters['strings_to_leak']

  file { '/opt/cron.sh':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0777',
    content => "#!/bin/bash -p\necho 'hello from cron' >> /tmp/cron.log\n",
  }

  cron { 'writable_cron_script':
    command => '/opt/cron.sh',
    user    => 'root',
    hour    => '*',
    minute  => '*',
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
