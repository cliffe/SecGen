class iceweasel::config {
  $secgen_params = secgen_functions::get_parameters($::base64_inputs_file)
  $accounts = $secgen_params['accounts']
  $autostart = str2bool($secgen_params['autostart'][0])
  $start_page = $secgen_params['start_page'][0]

  # Setup IW for each user account
  $accounts.each |$raw_account| {
    $account = parsejson($raw_account)
    $username = $account['username']

    # add user profile
    file { ["/home/$username/.mozilla/",
      "/home/$username/.mozilla/firefox",
      "/home/$username/.mozilla/firefox/user.default"]:
      ensure => directory,
      owner  => $username,
      group  => $username,
    }->
    file { "/home/$username/.mozilla/firefox/profiles.ini":
      ensure => file,
      source => 'puppet:///modules/iceweasel/profiles.ini',
      owner  => $username,
      group  => $username,
    }->

    # set start page via template:
    file { "/home/$username/.mozilla/firefox/user.default/user.js":
      ensure => file,
      content => template('iceweasel/user.js.erb'),
      owner  => $username,
      group  => $username,
    }

    # autostart script
    if $autostart {
      file { ["/home/$username/.config/", "/home/$username/.config/autostart/"]:
        ensure => directory,
        owner  => $username,
        group  => $username,
      }

      file { "/home/$username/.config/autostart/iceweasel.desktop":
        ensure => file,
        source => 'puppet:///modules/iceweasel/iceweasel.desktop',
        owner  => $username,
        group  => $username,
      }
    }
  }
}
