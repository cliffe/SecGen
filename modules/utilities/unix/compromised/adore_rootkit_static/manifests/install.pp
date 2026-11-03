class adore_rootkit_static::install {

  # TODO: rootkit configuration
  # $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  # $hidden_ports = join($secgen_parameters['hidden_ports'], "\|")
  # $hidden_strings = join($secgen_parameters['hidden_strings'], "\|")

  # The bundled binaries are 32-bit dynamically linked (ld-linux.so.2, libc.so.6).
  # `dpkg --add-architecture i386` + apt would normally provide those, but our
  # build mirror does not carry i386 Packages indices for bookworm (404 on
  # binary-i386), so we bundle the two shared objects (from the official
  # libc6:i386 package) and invoke the binaries via an explicit dynamic-linker
  # call instead of relying on multiarch + apt.
  $libdir = '/usr/lib/adore_rootkit_static'

  file { $libdir:
    ensure => directory,
    mode   => '0755',
    owner  => 'root',
    group  => 'root',
  }
  file { "${libdir}/ld-linux.so.2":
    source  => 'puppet:///modules/adore_rootkit_static/ld-linux.so.2',
    mode    => '0755',
    owner   => 'root',
    group   => 'root',
    require => File[$libdir],
  }
  file { "${libdir}/libc.so.6":
    source  => 'puppet:///modules/adore_rootkit_static/libc.so.6',
    mode    => '0755',
    owner   => 'root',
    group   => 'root',
    require => File[$libdir],
  }

  $binaries = {
    'ls_a'      => 'ls',
    'netstat_a' => 'netstat',
    'ps_a'      => 'ps',
  }
  $binaries.each |$wrapper_name, $source_name| {
    file { "${libdir}/${source_name}.bin":
      source  => "puppet:///modules/adore_rootkit_static/${source_name}",
      mode    => '0755',
      owner   => 'root',
      group   => 'root',
      require => File[$libdir],
    }
    file { "/bin/${wrapper_name}":
      ensure  => file,
      content => "#!/bin/sh\nexec ${libdir}/ld-linux.so.2 --library-path ${libdir} ${libdir}/${source_name}.bin \"\$@\"\n",
      mode    => '0755',
      owner   => 'root',
      group   => 'root',
      require => [File["${libdir}/ld-linux.so.2"], File["${libdir}/libc.so.6"], File["${libdir}/${source_name}.bin"]],
    }
  }

}
