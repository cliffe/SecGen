notice("THE MODULE internet history chrome was LOADED")

# include internet_history_chrome::init

$json_inputs = base64('decode', $::base64_inputs)
$secgen_parameters=parsejson($json_inputs)
$chrome_history_file_name=$secgen_parameters['chrome_history_file_name'][0]

# notice("Chrome history file value")
# notice($chrome_history_file_name)
# notice("Chrome history file value end")
#
#
# notice("THE MODULE internet history chrome was LOADED #2")
#
# $user_account = 'vagrant'
# $url_paths = ["https://www.offensive-security.com/backtrack/exploit-db-updates"]
#
# file { "C:\Users\{$user_account}\AppData\Roaming\Mozilla\Firefox\Profiles\{$mozilla_profile_number}.default\places.sqlite":
#
# }
#
# exec { "add-chrome-history":
#   command => "",
# }
#
# file { 'add-chrome-history':
#   ensure  => 'file',
#   ### path    => "C:/Users/$user_account/AppData/Local/Google/Chrome/User Data/Default/History",
#   path    => "C:/Users/$user_account/Desktop/test_file_here.txt",
#   ### content => template('internet_history_chrome/insert_history.erb')
#   # content => inline_template('evidence_windows_cybercrime_internet_history_chrome/insert_history.erb')
#   source => 'puppet:///modules/internet_history_chrome/chrome_history_file'
# }

class { 'internet_history_chrome':
  user_account => 'vagrant',
  history_file_name => 'History',
}

# file { "add-chrome-history-source":
#   path    => "C:/Users/$user_account/Desktop/History",
#   ensure => 'file',
#   # source => "puppet:///modules/internet_history_chrome/chrome_history_file",
#   # source => "puppet:///modules/file_transfer_storage_module/$chrome_history_file_name",
#   source => "puppet:///modules/file_transfer_storage_module/History",
# }

# file { "add-chrome-history-source":
#   path    => "C:/Users/$user_account/Desktop/test_file_here_source.txt",
#   ensure => 'file',
#   # source => "puppet:///modules/internet_history_chrome/chrome_history_file",
#   source => "puppet:///modules/internet_history_chrome/History_test_source_move",
# }

# file { 'add-chrome-history-content':
#   ensure  => 'file',
#   path    => "C:/Users/$user_account/Desktop/test_file_here_content.txt",
#   content => inline_template('evidence_windows_cybercrime_internet_history_chrome/insert_history.erb')
# }