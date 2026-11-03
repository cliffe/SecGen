class thunderbird::config {
  $secgen_params = secgen_functions::get_parameters($::base64_inputs_file)
  $accounts = $secgen_params['accounts']
  $autostart = str2bool($secgen_params['autostart'][0])
  $start_page = $secgen_params['start_page'][0]

  # Setup TB for each user account
  unless $accounts == undef {
    $accounts.each |$raw_account| {
      $account = parsejson($raw_account)
      $username = $account['username']

      # add user profile
      # the home directory belongs to the accounts module, so it is not declared here
      file { ["/home/$username/.thunderbird",
        "/home/$username/.thunderbird/user.default"]:
        ensure => directory,
        owner  => $username,
        group  => $username,
      } ->
      file { "/home/$username/.thunderbird/profiles.ini":
        ensure => file,
        source => 'puppet:///modules/thunderbird/profiles.ini',
        owner  => $username,
        group  => $username,
      } ->

      # set accounts via template:
      file { "/home/$username/.thunderbird/user.default/user.js":
        ensure  => file,
        content => template('thunderbird/user.js.erb'),
        owner   => $username,
        group   => $username,
      }

      # autostart script
      if $autostart {
        # ensure_resource: other modules may declare the same per-user directories
        ensure_resource('file', ["/home/$username/.config", "/home/$username/.config/autostart"], {
          'ensure' => 'directory',
          'owner'  => $username,
          'group'  => $username,
        })

        file { "/home/$username/.config/autostart/thunderbird.desktop":
          require => File["/home/$username/.config/autostart"],
          ensure => file,
          source => 'puppet:///modules/thunderbird/thunderbird.desktop',
          owner  => $username,
          group  => $username,
        }
      }
    }
  }
}
