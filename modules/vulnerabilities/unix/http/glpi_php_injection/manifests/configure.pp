# Class: glpi_php_injection::configure
# Configuration for glpi/ Secgen
#
class glpi_php_injection::configure {
  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $leaked_filenames = $secgen_parameters['leaked_filenames']
  $strings_to_leak = $secgen_parameters['strings_to_leak']

  ::secgen_functions::leak_files { 'glpi-flag-leak':
    storage_directory => '/var/www/html/glpi/vendor/htmlawed/htmlawed',
    leaked_filenames  => $leaked_filenames,
    strings_to_leak   => $strings_to_leak,
    owner             => 'www-data',
    mode              => '0750',
    leaked_from       => 'glpi_php_injection',
  }
}
