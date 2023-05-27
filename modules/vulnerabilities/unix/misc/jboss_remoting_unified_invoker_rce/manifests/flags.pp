class jboss_remoting_unified_invoker_rce::flags {
  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $leaked_filenames = $secgen_parameters['leaked_filenames']
  $strings_to_leak = $secgen_parameters['strings_to_leak']

  ::secgen_functions::leak_files { 'jboss-flag':
    storage_directory => '/opt/jboss-6.1.0.Final',
    leaked_filenames  => $leaked_filenames,
    strings_to_leak   => $strings_to_leak,
    leaked_from       => 'jboss',
  }
}
