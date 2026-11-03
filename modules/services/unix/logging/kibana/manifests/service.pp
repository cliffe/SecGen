class kibana::service (
  $kibana_ip = 'localhost',
  $kibana_port = '5601',
) {
  Exec { path => ['/bin','/sbin','/usr/bin', '/usr/sbin'] }

  service { 'kibana':
    ensure     => running,
    enable     => true,
    hasrestart => true,
  }

  # Kibana takes a minute or more to start answering, and returns 503 until it
  # can reach Elasticsearch. Wait (bounded) for a non-5xx reply; never fail the
  # build, as the Elasticsearch it reads from may be on another system that
  # is not up yet.
  exec { 'kibana wait until ready':
    command   => "for i in \$(seq 1 36); do code=\$(curl -s -o /dev/null -w '%{http_code}' http://${kibana_ip}:${kibana_port}/api/status); case \"\$code\" in 2*|3*|401|403) exit 0;; esac; sleep 5; done; exit 0",
    provider  => shell,
    timeout   => 240,
    logoutput => true,
    require   => Service['kibana'],
  }
}
