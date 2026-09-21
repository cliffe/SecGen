class ergochat::config {
  # /etc/ergochat/ircd.yaml is a real dpkg conffile, and (like most Debian
  # systemd packages) the service is started automatically as part of
  # package installation. So this must be written *after*
  # Package['ergochat'] (otherwise dpkg would overwrite it on this fresh
  # install) and must notify Service['ergochat'] so it restarts onto our
  # config instead of the one it auto-started with.
  file { '/etc/ergochat/ircd.yaml':
    ensure  => present,
    source  => 'puppet:///modules/ergochat/ircd.yaml',
    owner   => 'root',
    group   => 'ergochat',
    mode    => '0640',
    require => Package['ergochat'],
    notify  => Service['ergochat'],
  }
}
