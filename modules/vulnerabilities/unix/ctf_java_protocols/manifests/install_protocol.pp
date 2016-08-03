define ctf_java_protocols::install_protocol($detail_str = $title) {
  include stdlib

  $detail_arr = split($detail_str, ':')
  $exercise = $detail_arr[0]
  $protocol = join([$detail_arr[1], "Protocol"])
  if (size($detail_arr) >= 3) {
    $port = $detail_arr[2]
  } else {
    $port = 0
  }

  $token = gentoken($exercise)

  if("${protocol}" != '') {
    # Copy version with token
    file {"${protocol}_token":
      path => "/root/tmp/${protocol}.java",
      content => template("ctf_java_protocols/dirty/${protocol}.java.erb"),
      owner => 'root',
      group => 'root',
      mode => '0700',
      before => Exec["${protocol}_compile"],
      require => File['/root/tmp'],
    }

    # Compile Server and remove source code
    exec { "${protocol}_compile":
      command => "javac ${protocol}.java &&
      mv ${protocol}.class /root/${protocol}.class &&
      rm /root/tmp/${protocol}.java",
      path => '/usr/bin/:/bin',
      cwd => '/root/tmp',
      require => File['/root/tmp'],
      before => Exec["compile_encryption_${protocol}"],
    }

  exec {"compile_encryption_${protocol}":
      command => "java EncryptClass ${protocol}.class",
      path => '/usr/bin/:/bin',
      cwd => '/root/',
      require => Exec['compile_class']
  }

    # Copy version without token
    file { "${protocol}_clean":
      path => "/home/charlie/${protocol}/",
      source => "puppet:///modules/ctf_java_protocols/clean/${protocol}/",
      owner => "charlie",
      group => "charlie",
      mode => "0600",
      recurse => true,
      ensure => directory,
    }

    # Creates every protocol start
    if $::in_container == true{
      file_line { "${protocol}_start":
        line => "java RunProtocol ${port} ${protocol}.class &",
        path => '/etc/my_init.d/startprotocol',
        require => File["startprotocol"],
      }
    } else {
      file_line { "${protocol}_start":
        line => "java RunProtocol ${port} ${protocol}.class &",
        path => '/etc/init.d/startprotocol',
        require => File["startprotocol"],
      }
    }
  }
}
