class irc2::install{
  package { ['ircd-irc2']:
    ensure => 'installed',
  }
}
