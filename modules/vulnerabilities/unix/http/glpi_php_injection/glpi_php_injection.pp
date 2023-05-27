contain glpi_php_injection::install
contain glpi_php_injection::apache
contain glpi_php_injection::maria
contain glpi_php_injection::configure
Class['glpi_php_injection::install']
-> Class['glpi_php_injection::apache']
-> Class['glpi_php_injection::maria']
-> Class['glpi_php_injection::configure']
