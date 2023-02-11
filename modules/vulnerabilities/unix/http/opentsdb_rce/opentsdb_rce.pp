contain opentsdb_rce::install
contain opentsdb_rce::service
contain opentsdb_rce::configure
Class['opentsdb_rce::install']
-> Class['opentsdb_rce::service']
-> Class['opentsdb_rce::configure']
