# Leaves a detached interactive shell running whose in-memory history holds a
# command carrying a token. The command never reaches an on-disk history file,
# so it is recoverable only from a RAM capture (searched with strings).
class bash_history_artefact::install {
  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $flag = $secgen_parameters['flag'][0]

  ensure_packages(['gcc', 'libc6-dev', 'tmux'])

  $dropdir = '/opt/.audit'

  ::secgen_functions::create_directory { 'create audit dropdir':
    res  => 'bash_hist_dropdir',
    path => $dropdir,
  }

  # XOR-obfuscated decoder source; compiled, then the source is removed so the
  # token is not present in plaintext anywhere on disk.
  file { "${dropdir}/hist.c":
    ensure  => file,
    content => template('bash_history_artefact/payload_hist.c.erb'),
    mode    => '0600',
    require => ::Secgen_functions::Create_directory['create audit dropdir'],
  }

  exec { 'compile hist decoder':
    command => "gcc -O2 -o /usr/local/sbin/.hist-decode ${dropdir}/hist.c && rm -f ${dropdir}/hist.c",
    path    => ['/usr/bin', '/bin', '/usr/local/bin'],
    creates => '/usr/local/sbin/.hist-decode',
    require => [File["${dropdir}/hist.c"], Package['gcc'], Package['libc6-dev']],
  }

  file { '/usr/local/sbin/.hist-decode':
    ensure  => file,
    mode    => '0700',
    require => Exec['compile hist decoder'],
  }

  file { '/usr/local/sbin/session-audit-shell':
    ensure  => file,
    source  => 'puppet:///modules/bash_history_artefact/session-audit-shell.sh',
    mode    => '0755',
    require => Exec['compile hist decoder'],
  }

  file { '/etc/systemd/system/session-audit-shell.service':
    ensure => file,
    source => 'puppet:///modules/bash_history_artefact/session-audit-shell.service',
    mode   => '0644',
  }

  exec { 'enable session-audit-shell':
    command => 'systemctl daemon-reload && systemctl enable --now session-audit-shell.service',
    path    => ['/usr/bin', '/bin', '/usr/sbin', '/sbin'],
    require => [
      File['/usr/local/sbin/session-audit-shell'],
      File['/etc/systemd/system/session-audit-shell.service'],
      File['/usr/local/sbin/.hist-decode'],
      Package['tmux'],
    ],
  }
}
