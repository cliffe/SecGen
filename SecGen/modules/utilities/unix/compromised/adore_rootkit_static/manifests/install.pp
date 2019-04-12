class adore_rootkit_static::install {

  # TODO: rootkit configuration
  # $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  # $hidden_ports = join($secgen_parameters['hidden_ports'], "\|")
  # $hidden_strings = join($secgen_parameters['hidden_strings'], "\|")

  file { '/bin/ls_a':
    source => 'puppet:///modules/adore_rootkit_static/ls',
    mode   => '0755',
    owner => 'root',
    group => 'root',
  }
  file { '/bin/netstat_a':
    source => 'puppet:///modules/adore_rootkit_static/netstat',
    mode   => '0755',
    owner => 'root',
    group => 'root',
  }
  file { '/bin/ps_a':
    source => 'puppet:///modules/adore_rootkit_static/ps',
    mode   => '0755',
    owner => 'root',
    group => 'root',
  }

}
