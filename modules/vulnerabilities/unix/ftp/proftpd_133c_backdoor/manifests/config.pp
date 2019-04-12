class proftpd_133c_backdoor::config {
  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $raw_org = $secgen_parameters['organisation']
  if $raw_org and $raw_org[0] and $raw_org[0] != '' {
    $organisation = parsejson($raw_org[0])
  } else {
    $organisation = ''
  }
    file { '/etc/proftpd/proftpd.conf':
    ensure   => present,
    owner    => 'root',
    group    => 'root',
    mode     => '0644',
    content  => template('proftpd_133c_backdoor/proftpd.erb')
  }
}