contain lucee_rce::install
contain lucee_rce::service
contain lucee_rce::configure
Class['lucee_rce::install']
-> Class['lucee_rce::configure']
-> Class['lucee_rce::service']
