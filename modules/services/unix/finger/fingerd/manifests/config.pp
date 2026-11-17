class fingerd::config {
  # Add an enabled finger line (IPv4, no tcpd, so nothing else needs installing)
  # unless the postinst already registered one.
  exec { 'fingerd-inetd-entry':
    command => '/bin/sh -c "echo \'finger stream tcp nowait nobody /usr/sbin/in.fingerd in.fingerd\' >> /etc/inetd.conf"',
    unless  => '/bin/grep -Eq "^finger[[:space:]]" /etc/inetd.conf',
    require => Package['openbsd-inetd', 'finger', 'fingerd'],
    notify  => Service['inetd'],
  }

  service { 'inetd':
    ensure  => 'running',
    enable  => true,
    require => Package['openbsd-inetd', 'finger', 'fingerd'],
  }
}
