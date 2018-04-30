class proftpd::configure {
  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  file { '/etc/proftpd/proftpd.conf':
    notify   => Service['proftpd'],
    ensure   => present,
    owner    => 'root',
    group    => 'root',
    mode     => '0644',
    content  => template('proftpd/proftpd.erb'),
  }
}