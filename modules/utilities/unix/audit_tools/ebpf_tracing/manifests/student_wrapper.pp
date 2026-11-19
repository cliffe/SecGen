# When student_wrapper is true, installs /usr/local/sbin/tracee-watch and lets every user run it
# with sudo, so a user without root can trace their own programs with Tracee's fixed event set.
class ebpf_tracing::student_wrapper {
  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)

  if str2bool($secgen_parameters['student_wrapper'][0]) {
    ensure_packages(['sudo'])

    file { '/usr/local/sbin/tracee-watch':
      ensure  => file,
      owner   => 'root',
      group   => 'root',
      mode    => '0755',
      source  => 'puppet:///modules/ebpf_tracing/tracee-watch',
      require => Class['ebpf_tracing::install'],
    }

    file { '/etc/sudoers.d/tracee-watch':
      ensure       => file,
      owner        => 'root',
      group        => 'root',
      mode         => '0440',
      content      => "ALL ALL=(root) NOPASSWD: /usr/local/sbin/tracee-watch\n",
      validate_cmd => '/usr/sbin/visudo -cf %',
      require      => [Package['sudo'], File['/usr/local/sbin/tracee-watch']],
    }
  }
}
