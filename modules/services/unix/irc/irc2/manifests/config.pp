class irc2::config{
  service { 'ircd-irc2':
    enable => true,
    ensure => 'running',
  }
}
