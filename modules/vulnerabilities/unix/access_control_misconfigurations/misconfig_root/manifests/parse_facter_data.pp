class misconfig_root::parse_facter_data {
  # include 'stdlib'

  $file_input2 = regsubst($file_input,':','"','G')
  $file_input3 = regsubst($file_input2,'\s|=|{|}','\1','G')
  $file_input4 = regsubst($file_input3,'>',':','G')

  $file_input5 = split($file_input4, Regexp['[:,]'])

  class { 'misconfig_root::change_root_permissions':
    facter_used => true,
    files_to_change_permissions => $file_input5,
  }
}