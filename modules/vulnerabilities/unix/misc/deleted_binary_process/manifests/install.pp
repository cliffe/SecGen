# Builds a small payload that decodes a flag into memory at runtime, then runs
# it from a copy it immediately unlinks, so the process keeps running with no
# backing file on disk. The flag is XOR-obfuscated in the compiled binary, so it
# is recoverable only from the running process's memory (or a RAM capture).
class deleted_binary_process::install {
  Exec { path => ['/bin', '/usr/bin', '/usr/local/bin', '/sbin', '/usr/sbin'] }

  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $flag = $secgen_parameters['flag'][0]

  ensure_packages(['gcc', 'libc6-dev'])

  $dropdir = '/opt/.systemd-helper'
  file { $dropdir:
    ensure => directory,
    owner  => root,
    group  => root,
    mode   => '0700',
  }

  # Source carries the flag only as XOR-encoded bytes; it is removed after build.
  file { "${dropdir}/payload.c":
    ensure  => file,
    content => template('deleted_binary_process/payload.c.erb'),
    owner   => root,
    group   => root,
    mode    => '0600',
    require => File[$dropdir],
  }

  exec { 'compile deleted-binary payload':
    command => "gcc -O2 -o ${dropdir}/.udev-net-helper ${dropdir}/payload.c && rm -f ${dropdir}/payload.c",
    creates => "${dropdir}/.udev-net-helper",
    require => [File["${dropdir}/payload.c"], Package['gcc']],
  }

  file { '/usr/local/sbin/udev-net-helper':
    ensure => file,
    source => 'puppet:///modules/deleted_binary_process/launcher.sh',
    owner  => root,
    group  => root,
    mode   => '0755',
  }

  file { '/etc/systemd/system/udev-net-helper.service':
    ensure => file,
    source => 'puppet:///modules/deleted_binary_process/udev-net-helper.service',
    mode   => '0644',
  }

  exec { 'enable and start udev-net-helper':
    command => 'systemctl daemon-reload && systemctl enable --now udev-net-helper.service',
    unless  => 'systemctl is-active udev-net-helper.service',
    require => [
      File['/etc/systemd/system/udev-net-helper.service'],
      File['/usr/local/sbin/udev-net-helper'],
      Exec['compile deleted-binary payload'],
    ],
  }
}
