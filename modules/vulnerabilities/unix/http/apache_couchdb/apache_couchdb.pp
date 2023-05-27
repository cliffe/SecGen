# begining of puppet code execution
contain apache_couchdb::install
contain apache_couchdb::couchdb
contain apache_couchdb::configure
Class['apache_couchdb::install']
-> Class['apache_couchdb::couchdb']
-> Class['apache_couchdb::configure']
