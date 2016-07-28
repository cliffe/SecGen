class misconfig_uid::parse_facter_data {
  $file_input2 = regsubst($file_input,':','"','G')
  $file_input3 = regsubst($file_input2,'\s|=|{|}','\1','G')
  $file_input4 = regsubst($file_input3,'>',':','G')

  $file_input5 = split($file_input4, Regexp['[:,]'])

  class { 'misconfig_uid::change_uid':
    facter_used => true,
    file_input => $file_input5,
  }
}