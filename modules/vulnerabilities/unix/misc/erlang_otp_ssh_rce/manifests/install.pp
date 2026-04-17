class erlang_otp_ssh_rce::install {
  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $leaked_filenames = $secgen_parameters['leaked_filenames']
  $strings_to_leak = $secgen_parameters['strings_to_leak']
  $ssh_username = $secgen_parameters['unix_username'][0]
  $ssh_home = "/home/${ssh_username}"
  $status_log = '/var/log/erlang_otp_ssh_rce/stage_status.log'

  ensure_packages([
    'build-essential',
    'autoconf',
    'm4',
    'util-linux',
    'libncurses5-dev',
    'libssl-dev',
    'unixodbc-dev',
    'xsltproc',
    'fop',
    'screen',
    'openssh-client',
  ])

  file { '/var/log/erlang_otp_ssh_rce':
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  file { '/tmp/otp-OTP-26.2.5.10.tar.gz':
    ensure => file,
    source => 'puppet:///modules/erlang_otp_ssh_rce/otp-OTP-26.2.5.10.tar.gz',
    mode   => '0644',
  }

  exec { 'extract-erlang-otp-source':
    command => 'tar -xzf /tmp/otp-OTP-26.2.5.10.tar.gz -C /tmp',
    creates => '/tmp/otp-OTP-26.2.5.10',
    path    => ['/usr/bin', '/bin'],
    logoutput => true,
    require => File['/tmp/otp-OTP-26.2.5.10.tar.gz'],
  }

  exec { 'erlang-otp-build-preflight':
    command => "/bin/sh -c 'echo \"=== Erlang OTP build preflight ===\" > /var/log/erlang_otp_ssh_rce/preflight.log; date >> /var/log/erlang_otp_ssh_rce/preflight.log; uname -a >> /var/log/erlang_otp_ssh_rce/preflight.log; command -v gcc >> /var/log/erlang_otp_ssh_rce/preflight.log 2>&1; command -v make >> /var/log/erlang_otp_ssh_rce/preflight.log 2>&1; ls -lh /tmp/otp-OTP-26.2.5.10.tar.gz >> /var/log/erlang_otp_ssh_rce/preflight.log 2>&1; df -h /tmp /usr/local >> /var/log/erlang_otp_ssh_rce/preflight.log 2>&1; echo \"$(date -Is) preflight:ok\" >> ${status_log}; touch /var/log/erlang_otp_ssh_rce/.preflight_done'",
    creates  => '/var/log/erlang_otp_ssh_rce/.preflight_done',
    path     => ['/usr/bin', '/bin'],
    logoutput => true,
    require  => [
      File['/var/log/erlang_otp_ssh_rce'],
      Exec['extract-erlang-otp-source'],
    ],
  }

  exec { 'configure-erlang-otp-source':
    command => "/bin/sh -c 'echo \"$(date -Is) configure:start\" >> ${status_log}; if /bin/sh /tmp/otp-OTP-26.2.5.10/configure --prefix=/usr/local > /var/log/erlang_otp_ssh_rce/configure.log 2>&1; then echo \"$(date -Is) configure:ok\" >> ${status_log}; touch /var/log/erlang_otp_ssh_rce/.configure_ok; else rc=$?; echo \"$(date -Is) configure:fail rc=\$rc\" >> ${status_log}; touch /var/log/erlang_otp_ssh_rce/.configure_fail; tail -n 80 /var/log/erlang_otp_ssh_rce/configure.log >> ${status_log}; exit \$rc; fi'",
    cwd     => '/tmp/otp-OTP-26.2.5.10',
    creates => '/tmp/otp-OTP-26.2.5.10/Makefile',
    path    => ['/usr/bin', '/bin'],
    timeout => 0,
    logoutput => true,
    require => Exec['erlang-otp-build-preflight'],
  }

  exec { 'build-erlang-otp-source':
    command => "/bin/sh -c 'echo \"$(date -Is) build:start\" >> ${status_log}; if /usr/bin/make > /var/log/erlang_otp_ssh_rce/build.log 2>&1; then echo \"$(date -Is) build:ok\" >> ${status_log}; touch /var/log/erlang_otp_ssh_rce/.build_ok; else rc=$?; echo \"$(date -Is) build:fail rc=\$rc\" >> ${status_log}; touch /var/log/erlang_otp_ssh_rce/.build_fail; tail -n 120 /var/log/erlang_otp_ssh_rce/build.log >> ${status_log}; exit \$rc; fi'",
    cwd     => '/tmp/otp-OTP-26.2.5.10',
    creates => '/tmp/otp-OTP-26.2.5.10/bin/erl',
    path    => ['/usr/bin', '/bin'],
    timeout => 0,
    logoutput => true,
    require => Exec['configure-erlang-otp-source'],
  }

  exec { 'install-erlang-otp-source':
    command => "/bin/sh -c 'echo \"$(date -Is) install:start\" >> ${status_log}; if /usr/bin/make install > /var/log/erlang_otp_ssh_rce/install.log 2>&1; then echo \"$(date -Is) install:ok\" >> ${status_log}; touch /var/log/erlang_otp_ssh_rce/.install_ok; else rc=$?; echo \"$(date -Is) install:fail rc=\$rc\" >> ${status_log}; touch /var/log/erlang_otp_ssh_rce/.install_fail; tail -n 120 /var/log/erlang_otp_ssh_rce/install.log >> ${status_log}; exit \$rc; fi'",
    cwd     => '/tmp/otp-OTP-26.2.5.10',
    creates => '/usr/local/bin/erl',
    path    => ['/usr/bin', '/bin'],
    timeout => 0,
    logoutput => true,
    require => Exec['build-erlang-otp-source'],
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
    require => File['/var/log/erlang_otp_ssh_rce'],
  }
}