define apache::namevirtualhost ($port=''){
  $addr_port = $name

  if defined(Concat[$::apache::ports_file]){
    # Template uses: $addr_port
    concat::fragment { "NameVirtualHost ${addr_port}":
      target  => $::apache::ports_file,
      content => template('apache/namevirtualhost.erb'),
    }
  } elsif $port != '80' {  # if a second vhost is declared off port 80
    # Create a temporary file
    # join with cat $tmp_file >> $file
    # remove tmp files
    $ports_file = $::apache::ports_file
    $tmp_file = "$ports_file-tmp_nvh"
    file { $tmp_file:
      ensure => file,
      content => template('apache/namevirtualhost.erb'),
    }

    exec { "apache::listen: cat $tmp_file with ports.conf":
      command => "/bin/cat $tmp_file >> $ports_file;/bin/rm $tmp_file",
      require => File[$tmp_file]
    }

  } else {  # if a second vhost is declared on port 80
    tidy { 'remove apache default site':
      path =>'/etc/apache2/sites-enabled/000-default',
    }
  }
}
