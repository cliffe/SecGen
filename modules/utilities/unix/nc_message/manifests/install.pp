class nc_message::install {
  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $port = $secgen_parameters['port'][0]

  # the cron type comes from the required cron puppet_module; crontab itself needs the cron package
  ensure_packages(["nmap", "cron"])
  case $operatingsystemrelease {
    /^(1[0-9]).*/: { # do buster stuff
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
    command     => "sleep 10 && ncat -l -p $port -c 'cat /root/cronncatmsg$port' -k &",
    special     => 'reboot',
    require     => Package['cron'],
  }

}
