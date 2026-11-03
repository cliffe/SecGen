class { '::mysql::server':
  override_options => {
    'mysqld' => {
      'ssl'         => undef,
      'ssl-ca'      => undef,
      'ssl-cert'    => undef,
      'ssl-key'     => undef,
      'ssl-disable' => true,
      # ssl-disable is a Puppet-side switch (my.cnf.erb drops it and the ssl-* keys);
      # skip-ssl is what MariaDB actually reads
      'skip-ssl'    => true
    }
  }
}

include '::mysql::client'
