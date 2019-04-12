define apache::listen ($port='') {
  $listen_addr_port = $name

  if defined(Concat[$::apache::ports_file]){
    # Template uses: $listen_addr_port
    concat::fragment { "Listen ${listen_addr_port}":
      target  => $::apache::ports_file,
      content => template('apache/listen.erb'),
    }
  } elsif $port != '80' {
    # Create a temporary file
    # join with cat $tmp_file >> $file
    # remove tmp files
    $ports_file = $::apache::ports_file
    $tmp_file = "$ports_file-tmp_listen"
    file { $tmp_file:
      ensure => file,
      content => template('apache/listen.erb'),
    }

    exec { "apache::listen: cat $tmp_file with ports.conf":
      command => "/bin/cat $tmp_file >> $ports_file;/bin/rm $tmp_file"
    }
  }
}
