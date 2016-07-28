class misconfig_gid::parse_facter_data {
  $file_input2 = regsubst($file_input,':','"','G') ##### <<<<< Replace all ':' characters with '"' characters
  $file_input3 = regsubst($file_input2,'\s|=|{|}','\1','G') ##### <<<<< Replace all spaces and '=' characters with null characters (nothing)
  $file_input4 = regsubst($file_input3,'>',':','G') ##### <<<<< Replace all '>' characters with ':' characters
  $file_input5 = split($file_input4, Regexp['[:,]'])

  class { 'misconfig_gid::change_gid':
    facter_used => true,
    file_input => $file_input5,
  }
}