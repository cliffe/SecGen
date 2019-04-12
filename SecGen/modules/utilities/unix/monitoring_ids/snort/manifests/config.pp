class snort::config{

  file { '/etc/snort/snort.debian.conf':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0777',
    content  => template('snort/snort.debian.conf.erb')
  }

  # enable the alerts file output
  file_line { 'Append a line to /etc/snort/snort.conf':
    path => '/etc/snort/snort.conf',
    line => 'output alert_fast',
  }

}
