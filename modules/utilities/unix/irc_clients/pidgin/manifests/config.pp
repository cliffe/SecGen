class pidgin::config {
  $secgen_params = secgen_functions::get_parameters($::base64_inputs_file)
  $accounts = $secgen_params['accounts']
  $autostart = str2bool($secgen_params['autostart'][0])
  $ip = $secgen_params['server_ip'][0]

  # Setup Pidgin for each user account
  $accounts.each |$raw_account| {
    $account = parsejson($raw_account)
    $username = $account['username']
    $conf_dir = "/home/$username/.purple"

    file { ["$conf_dir",
            "$conf_dir/smileys/",
            "$conf_dir/icons/",
            "$conf_dir/certificates",
            "$conf_dir/certificates/x509",
            "$conf_dir/certificates/x509/tls_peers"]:
      ensure  => directory,
      require => Package['pidgin'],
      owner  => $username,
      group  => $username,
    }

    file { "$conf_dir/accounts.xml":
      ensure  => file,
      content => template('pidgin/accounts.xml.erb'),
      require => File[$conf_dir],
    }
    file { "$conf_dir/blist.xml":
      ensure  => file,
      content => template('pidgin/blist.xml.erb'),
      require => File[$conf_dir],
    }
    file { "$conf_dir/pounces.xml":
      ensure  => file,
      content  => template('pidgin/pounces.xml.erb'),
      require => File[$conf_dir],
    }
    file { "$conf_dir/prefs.xml":
      ensure  => file,
      source  => 'puppet:///modules/pidgin/prefs.xml',
      require => File[$conf_dir],
    }
    file { "$conf_dir/status.xml":
      ensure  => file,
      source  => 'puppet:///modules/pidgin/status.xml',
      require => File[$conf_dir],
    }
    file { "$conf_dir/icons/skullandusb.svg":
      ensure  => file,
      source  => 'puppet:///modules/pidgin/skullandusb.svg',
      require => File[$conf_dir],
    }

    # autostart script
    if $autostart {
      file { ["/home/$username/.config/", "/home/$username/.config/autostart/"]:
        ensure => directory,
        owner  => $username,
        group  => $username,
      }

      file { "/home/$username/.config/autostart/pidgin.desktop":
        ensure => file,
        source => 'puppet:///modules/pidgin/pidgin.desktop',
        owner  => $username,
        group  => $username,
      }
    }
  }
}
