class gnuscreen::install {
  Exec { path => ['/bin', '/usr/bin', '/usr/local/bin', '/sbin', '/usr/sbin'] }

  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $leaked_filenames = $secgen_parameters['leaked_filenames']
  $strings_to_leak = $secgen_parameters['strings_to_leak']

  ensure_packages([ 'gcc', 'make', 'autoconf', 'libncurses5-dev'])

  file { '/opt/screen-4.5.0.tar.gz':
    ensure => file,
    source => 'puppet:///modules/gnuscreen/screen-4.5.0.tar.gz',
  }
  -> exec { 'untar screen':
    cwd => '/opt/',
    command => 'tar -xvf screen-4.5.0.tar.gz',
  }
  # The release tarball ships a generated configure; autogen.sh is only for git
  # checkouts, and Debian 12's autoconf rejects it (no install-sh).
  -> exec { 'exec configure':
    cwd => '/opt/screen-4.5.0',
    command => 'sh ./configure'
  }
  -> exec { 'exec make':
    cwd => '/opt/screen-4.5.0',
    command => 'make && make install'
  }

  # Leak a file containing a string/flag to /root/
  ::secgen_functions::leak_files { 'gnu-screen-file-leak':
    storage_directory => '/root',
    leaked_filenames => $leaked_filenames,
    strings_to_leak => $strings_to_leak,
    leaked_from => "gnuscreen",
    mode => '0600'
  }
}
