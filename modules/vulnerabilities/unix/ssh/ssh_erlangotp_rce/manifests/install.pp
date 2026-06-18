class ssh_erlangotp_rce::install {
  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $ssh_username = $secgen_parameters['unix_username'][0]
  $ssh_home = "/home/${ssh_username}"
  $status_log = '/var/log/ssh_erlangotp_rce/stage_status.log'

  ensure_packages([
    'openssh-client',
  ])

  file { '/var/log/ssh_erlangotp_rce':
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  file { '/tmp/erlang-otp-prebuilt_26.2.5.10-1_amd64.deb':
    ensure => file,
    source => 'puppet:///modules/ssh_erlangotp_rce/erlang-otp-prebuilt_26.2.5.10-1_amd64.deb',
    mode   => '0644',
  }

  exec { 'install-erlang-otp-prebuilt':
    command => "/bin/sh -c 'echo \"$(date -Is) install:start\" >> ${status_log}; if /usr/bin/dpkg -i /tmp/erlang-otp-prebuilt_26.2.5.10-1_amd64.deb > /var/log/ssh_erlangotp_rce/install.log 2>&1; then echo \"$(date -Is) install:ok\" >> ${status_log}; touch /var/log/ssh_erlangotp_rce/.install_ok; else rc=$?; echo \"$(date -Is) install:fail rc=\$rc\" >> ${status_log}; touch /var/log/ssh_erlangotp_rce/.install_fail; tail -n 120 /var/log/ssh_erlangotp_rce/install.log >> ${status_log}; exit \$rc; fi'",
    creates => '/usr/local/bin/erl',
    path    => ['/usr/bin', '/bin', '/usr/sbin', '/sbin'],
    logoutput => true,
    require => [
      File['/var/log/ssh_erlangotp_rce'],
      File['/tmp/erlang-otp-prebuilt_26.2.5.10-1_amd64.deb'],
    ],
  }

  user { $ssh_username:
    ensure     => present,
    home       => $ssh_home,
    managehome => true,
    shell      => '/bin/bash',
  }

  group { $ssh_username:
    ensure => present,
  }

  file { $status_log:
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => File['/var/log/ssh_erlangotp_rce'],
  }
}