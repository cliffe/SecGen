class internet_history_chrome ($user_account, $history_file_name) {
  # notice("THE MODULE internet history chrome was LOADED #2")

  # $user_account = 'vagrant'
  # $url_paths = ["https://www.offensive-security.com/backtrack/exploit-db-updates"]

  # file { "C:\Users\{$user_account}\AppData\Roaming\Mozilla\Firefox\Profiles\{$mozilla_profile_number}.default\places.sqlite":
  #
  # }

  # exec { "add-chrome-history":
  #   command => "",
  # }

  file { 'add-chrome-history':
    ensure  => 'present',
    path    => "C:/Users/$user_account/AppData/Local/Google/Chrome/User Data/Default/History",
    # path    => 'C:/Users/vagrant/AppData/Local/Google/Chrome/User Data/Default/History',
    # content => template('internet_history_chrome/insert_history.erb')
    # content => inline_template('evidence_windows_cybercrime_internet_history_chrome/insert_history.erb')
    source => "puppet:///modules/file_transfer_storage_module/History",
  }
}