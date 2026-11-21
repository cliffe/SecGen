# Builds a small binary that decodes a flag into its own environment at runtime,
# then execs a sleeper that inherits it. The flag is XOR-obfuscated in the
# compiled binary, so it is recoverable only from the running process's memory
# (or a RAM capture), never from a file on disk.
class env_secret_process::install {
  Exec { path => ['/bin', '/usr/bin', '/usr/local/bin', '/sbin', '/usr/sbin'] }

  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $flag = $secgen_parameters['flag'][0]

  ensure_packages(['gcc', 'libc6-dev'])

  $dropdir = '/opt/.telemetry'
  file { $dropdir:
    ensure => directory,
    owner  => root,
    group  => root,
    mode   => '0700',
  }

  # Source carries the flag only as XOR-encoded bytes; it is removed after build.
  file { "${dropdir}/telemetry.c":
    ensure  => file,
    content => template('env_secret_process/payload_env.c.erb'),
    owner   => root,
    group   => root,
    mode    => '0600',
    require => File[$dropdir],
  }

  exec { 'compile env-secret payload':
    command => "gcc -O2 -o /usr/local/sbin/net-telemetryd ${dropdir}/telemetry.c && rm -f ${dropdir}/telemetry.c",
    creates => '/usr/local/sbin/net-telemetryd',
    require => [File["${dropdir}/telemetry.c"], Package['gcc']],
  }

  file { '/etc/systemd/system/net-telemetry.service':
    ensure => file,
    source => 'puppet:///modules/env_secret_process/net-telemetry.service',
    mode   => '0644',
  }

  exec { 'enable and start net-telemetry':
    command => 'systemctl daemon-reload && systemctl enable --now net-telemetry.service',
    unless  => 'systemctl is-active net-telemetry.service',
    require => [
      File['/etc/systemd/system/net-telemetry.service'],
      Exec['compile env-secret payload'],
    ],
  }
}
