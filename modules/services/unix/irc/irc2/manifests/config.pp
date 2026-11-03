class irc2::config {
  $secgen_params = secgen_functions::get_parameters($::base64_inputs_file)
  $motd = $secgen_params['motd'][0]

  # The Debian package reads /etc/ircd/ircd.conf and /etc/ircd/ircd.motd
  # (compiled in), and creates /etc/ircd (root:irc 0750) on install, so these
  # must be written after the package. /etc/ircd.conf is never read.
  # The daemon runs as the irc user, hence group irc and mode 0640.
  file { '/etc/ircd/ircd.conf':
    ensure  => present,
    source  => 'puppet:///modules/irc2/ircd.conf',
    owner   => 'root',
    group   => 'irc',
    mode    => '0640',
    require => Package['ircd-irc2'],
    notify  => Service['ircd-irc2'],
  }

  file { '/etc/ircd/ircd.motd':
    ensure  => present,
    content => "${motd}\n",
    owner   => 'root',
    group   => 'irc',
    mode    => '0640',
    require => Package['ircd-irc2'],
    notify  => Service['ircd-irc2'],
  }

  # No iauth.conf is shipped: irc2::service starts ircd with -s, so the iauth
  # helper is never run and its config is never read. The packaged default
  # (required + rfc931) is what held clients at the 020 "Please wait" notice.
}
