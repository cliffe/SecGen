class nc_message::install {
  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $port = $secgen_parameters['port'][0]

  ensure_packages("nmap")
  case $operatingsystemrelease {
    /^(10).*/: { # do buster stuff
      ensure_packages("ncat")
    }
  }

  # join all the strings to leak
  # escape single quotes and semicolons, so we can use echo
  # $strings_to_leak = regsubst(join($secgen_parameters['strings_to_leak'], ","), "'|;", "\\\\\0")
  $strings_to_leak = join($secgen_parameters['strings_to_leak'], "\n")

  file { "/root/cronncatmsg$port":
    content     => $strings_to_leak,
    ensure      => present,
  }

  # run on each boot via cron
  cron { "cronncatmsg$port":
    command     => "sleep 60 && ncat -l -p $port -c 'cat /root/cronncatmsg$port' -k &",
    special     => 'reboot',
  }

}
