# Class: glpi_php_injection::configure
# Configuration for glpi/ Secgen
#
class glpi_php_injection::configure {
  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $leaked_filenames = $secgen_parameters['leaked_filenames']
  $strings_to_leak = $secgen_parameters['strings_to_leak']

  # Leaked outside the Apache docroot (/var/www/html/glpi/): the vhost has no
  # deny rule for vendor/, so a file under vendor/htmlawed/htmlawed/ would be
  # fetchable directly over HTTP, letting a student skip the PHP injection
  # entirely.  www-data owns it at mode 0700 so it is only readable via the
  # command execution the exploit grants, not Apache's own file serving.
  ::secgen_functions::leak_files { 'glpi-flag-leak':
    storage_directory => '/var/lib/glpi-secret',
    leaked_filenames  => $leaked_filenames,
    strings_to_leak   => $strings_to_leak,
    owner             => 'www-data',
    mode              => '0700',
    leaked_from       => 'glpi_php_injection',
  }
}
