class irc2::config {
  file { '/etc/ircd.conf':
    ensure => present,
    source => 'puppet:///modules/irc2/ircd.conf',
    before => Package['ircd-irc2'],
  }

  file { '/etc/ircd.motd':
    ensure => present,
    source => 'puppet:///modules/irc2/ircd.motd',
    before => Package['ircd-irc2'],
  }
}
