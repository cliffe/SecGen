class rancher::install {
  Exec {
    path => ['/bin', '/usr/bin', '/usr/local/bin', '/sbin', '/usr/sbin']
  }

  ensure_packages(['apt-transport-https', 'ca-certificates', 'curl', 'gnupg2', 'software-properties-common', 'python3-pip'])

  docker::run {'rancher-server':
    image => 'rancher/server',
    ports => ['8080:8080'],
    extra_parameters => '--restart=unless-stopped',
  } ->
  exec {'wait-for-rancher-server':
    command => 'sleep 360',
    timeout => 365,
  } ->
#  docker::image {'rancher/net': } ->
#  docker::image {'rancher/network-manager': } ->
#  docker::image {'rancher/dns': } ->
#  docker::image {'rancher/healthcheck': } ->
#  docker::image {'rancher/metadata': } ->
#  docker::image {'rancher/scheduler': } ->
  docker::image {'rancher/agent':
    tag => 'v1.2.11',
  } ->
  docker::image {'alpine': } ->
  file {'/root/setup-rancher.py':
    source => 'puppet:///modules/rancher/setup-rancher.py',
    mode => '0755',
  } ->
  exec {'install-debinterface':
    command => 'pip3 install debinterface'
  } ->
#  exec {'configure-rancher':
#    command => 'python3 /root/setup-rancher.py',
#    environment => [],
#  } ->
  exec {'set-rancher-configuration-file-to-run-at-boot-via-crontab':
    command => 'echo "@reboot root /usr/bin/python3 /root/setup-rancher.py >> /root/rancher_config_log.txt 2>> /root/rancher_config_log.txt" >> /etc/crontab; chmod 644 /etc/crontab'
  }
}
