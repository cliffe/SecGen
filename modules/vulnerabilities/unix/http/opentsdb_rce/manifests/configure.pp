# Class: opentsdb_rce::configure
# Configuration for secgen
#
class opentsdb_rce::configure {
  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)

  $leaked_filenames = $secgen_parameters['leaked_filenames']
  $strings_to_leak = $secgen_parameters['strings_to_leak']

  Exec { path => ['/bin', '/usr/bin', '/usr/local/bin', '/sbin', '/usr/sbin'] }

  ::secgen_functions::leak_files { 'opentsdb-flag-leak':
    storage_directory => '/usr/share/opentsdb/bin/',
    leaked_filenames  => $leaked_filenames,
    strings_to_leak   => $strings_to_leak,
    owner             => 'root',
    mode              => '0750',
    leaked_from       => 'opentsdb_rce',
  }
}
