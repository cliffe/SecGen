class distcc_exec::config{
  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $leaked_filenames = $secgen_parameters['leaked_filenames']
  $strings_to_leak = $secgen_parameters['strings_to_leak']

  file { '/etc/default/distcc':
    require => Package['distcc'],
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0777',
    content  => template('distcc_exec/distcc.erb')
  }

  # distccd home directory
  file { '/home/distccd/':
    ensure => directory,
    owner => 'distccd',
    mode  =>  '0750',
  }

  #exec usermod home directory for distccd
  exec { 'change-home-dir':
    path => ['/usr/bin/', '/usr/sbin'],
    command => 'usermod -d /home/distccd distccd'
  }

  # newer versions of distcc have a directory of symlinks for whitelisting compilers
  exec {"check_presence_compiler_list":
    command => '/bin/ln -s /bin/sh /usr/lib/distcc/sh',
    onlyif => '/usr/bin/test -d /usr/lib/distcc -a ! -e /usr/lib/distcc/sh',
  }

  ::secgen_functions::leak_files { 'distcc_exec-file-leak':
    storage_directory => "/home/distccd",
    leaked_filenames  => $leaked_filenames,
    strings_to_leak   => $strings_to_leak,
    owner             => 'distccd',
    mode              => '0600',
    leaked_from       => 'distcc_exec',
  }
}
