# Class: log4shell_header_injection::configure
# Leak the flag into the service user's home, where the shell the exploit lands
# (running as that user) can read it.
class log4shell_header_injection::configure {
  $modulename = 'log4shell_header_injection'
  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $user = $secgen_parameters['unix_username'][0]
  $strings_to_leak = $secgen_parameters['strings_to_leak']
  $leaked_filenames = $secgen_parameters['leaked_filenames']

  ::secgen_functions::leak_files { 'log4shell_header_injection_leak':
    storage_directory => "/home/${user}",
    leaked_filenames  => $leaked_filenames,
    strings_to_leak   => $strings_to_leak,
    owner             => $user,
    mode              => '0750',
    leaked_from       => 'log4shell_header_injection',
  }
}
