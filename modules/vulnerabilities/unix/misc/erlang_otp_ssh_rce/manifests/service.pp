class erlang_otp_ssh_rce::service {
  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $ssh_port = pick($secgen_parameters['ssh_port'], ['2222'])
  $port = $ssh_port[0]
  $ssh_username = $secgen_parameters['unix_username'][0]

  exec { 'generate-ssh-host-rsa-key':
    command => "/bin/sh -c '/usr/sbin/runuser -u ${ssh_username} -- ssh-keygen -t rsa -b 2048 -f /opt/erlang_ssh/ssh_keys/ssh_host_rsa_key -N \"\" > /var/log/erlang_otp_ssh_rce/ssh_keygen_rsa.log 2>&1'",
    path    => ['/usr/sbin', '/usr/bin', '/sbin', '/bin'],
    creates => '/opt/erlang_ssh/ssh_keys/ssh_host_rsa_key',
    logoutput => true,
    require => [
      File['/var/log/erlang_otp_ssh_rce'],
      File['/opt/erlang_ssh/ssh_keys'],
      User[$ssh_username],
    ],
  }

  exec { 'generate-ssh-host-ecdsa-key':
    command => "/bin/sh -c '/usr/sbin/runuser -u ${ssh_username} -- ssh-keygen -t ecdsa -b 256 -f /opt/erlang_ssh/ssh_keys/ssh_host_ecdsa_key -N \"\" > /var/log/erlang_otp_ssh_rce/ssh_keygen_ecdsa.log 2>&1'",
    path    => ['/usr/sbin', '/usr/bin', '/sbin', '/bin'],
    creates => '/opt/erlang_ssh/ssh_keys/ssh_host_ecdsa_key',
    logoutput => true,
    require => Exec['generate-ssh-host-rsa-key'],
  }

  file { '/etc/systemd/system/erlang-otp-ssh-rce.service':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => @("UNIT"),
[Unit]
Description=Erlang OTP vulnerable SSH daemon
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=${ssh_username}
Group=${ssh_username}
WorkingDirectory=/opt/erlang_ssh
ExecStart=/usr/local/bin/escript /opt/erlang_ssh/start_ssh.escript ${port}
Restart=on-failure
RestartSec=3
StandardOutput=append:/var/log/erlang_otp_ssh_rce/ssh_daemon_start.log
StandardError=append:/var/log/erlang_otp_ssh_rce/ssh_daemon_start.log

[Install]
WantedBy=multi-user.target
| UNIT
    notify  => Exec['systemd-daemon-reload'],
    require => [
      File['/var/log/erlang_otp_ssh_rce'],
      Exec['generate-ssh-host-ecdsa-key'],
      File['/opt/erlang_ssh/start_ssh.escript'],
      Exec['install-erlang-otp-source'],
      User[$ssh_username],
    ],
  }

  exec { 'systemd-daemon-reload':
    command     => '/bin/systemctl daemon-reload',
    path        => ['/usr/bin', '/bin', '/usr/sbin', '/sbin'],
    refreshonly => true,
  }

  service { 'erlang-otp-ssh-rce':
    ensure    => running,
    enable    => true,
    provider  => 'systemd',
    subscribe => [
      File['/etc/systemd/system/erlang-otp-ssh-rce.service'],
      File['/opt/erlang_ssh/start_ssh.escript'],
    ],
    require   => [
      Exec['systemd-daemon-reload'],
      Exec['generate-ssh-host-ecdsa-key'],
    ],
  }
}