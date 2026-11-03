class before_login_message::init {

  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)

  # The default input is an empty <value/>, which arrives as [""]. Skip empty
  # strings so the module never appends blank lines or declares empty titles.
  $messages = $secgen_parameters['strings_to_leak'].filter |$m| { $m != '' }

  # One file_line per message (unique titles via the index), written to the
  # local console banner and to the network (ssh/telnet) banner.
  $messages.each |Integer $i, String $message| {
    file_line { "before_login_message issue ${i}":
      path => '/etc/issue',
      line => $message,
    }
    file_line { "before_login_message issue.net ${i}":
      path => '/etc/issue.net',
      line => $message,
    }
  }
}
