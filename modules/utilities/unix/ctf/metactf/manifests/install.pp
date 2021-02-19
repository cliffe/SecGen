class metactf::install {
  $secgen_params = secgen_functions::get_parameters($::base64_inputs_file)
  $install_dir = '/tmp/metactf'

  Exec { path => ['/bin', '/usr/bin', '/usr/local/bin', '/sbin', '/usr/sbin'] }

  ensure_packages('build-essential')
  ensure_packages('gcc-multilib')

  file { $install_dir:
    ensure  => directory,
    recurse => true,
    source  => 'puppet:///modules/metactf/repository',
  }

  exec { 'set install.sh mode':
    command => "chmod +x $install_dir/install.sh",
    logoutput => on_failure,
  }

  exec { 'install metactf dependencies':
    command => "/bin/bash $install_dir/install.sh",
    logoutput => on_failure,
  }

  # For now just build all of the binaries.
  exec { 'build src_angr binaries':
    cwd     => "$install_dir/src_angr/",
    logoutput => on_failure,
    command => "/usr/bin/make",
  }

  # Build src_csp
  exec { 'src_csp chmod executable':
    command => 'chmod -R +x */*/*.zsh',
    cwd     => "$install_dir/src_csp/",
    logoutput => on_failure,
  }

  exec { 'build src_csp binaries':
    cwd     => "$install_dir/src_csp/",
    command => "/usr/bin/make",
    require => Exec['src_csp chmod executable'],
  }

  # Build src_malware
  exec { 'src_malware chmod executable':
    command => 'chmod -R +x */*/*.zsh',
    cwd     => "$install_dir/src_malware/",
    logoutput => on_failure,
  }

  # Build src_malware
  exec { 'build src_malware binaries':
    cwd     => "$install_dir/src_malware/",
    command => "/usr/bin/make",
    logoutput => on_failure,
    require => Exec['src_malware chmod executable'],
  }

  # Build src_sse
  exec { 'src_sse chmod executable':
    command => 'chmod -R +x */*/*.zsh',
    cwd     => "$install_dir/src_sse/",
    logoutput => on_failure,
  }

  # Build src_sse
  exec { 'build src_sse binaries':
    cwd     => "$install_dir/src_sse/",
    command => "/usr/bin/make",
    logoutput => on_failure,
    require => Exec['src_sse chmod executable'],
  }

}
