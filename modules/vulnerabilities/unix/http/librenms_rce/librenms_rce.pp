# begining of puppet code execution

contain librenms_rce::install
contain librenms_rce::librenms
contain librenms_rce::webserver
Class['librenms_rce::install'] ->
Class['librenms_rce::librenms'] ->
Class['librenms_rce::webserver']