class gid_ifconfig::parse_facter_data /* ($facter_variable_name = $file_input) */ {
  $file_input2 = regsubst($file_input,':','"','G') ##### <<<<< Replace all ':' characters with '"' characters
  $file_input3 = regsubst($file_input2,'\s|=|{|}','\1','G') ##### <<<<< Replace all spaces and '=' characters with null characters (nothing)
  $file_input4 = regsubst($file_input3,'>',':','G') ##### <<<<< Replace all '>' characters with ':' characters
  $file_input5 = split($file_input4, Regexp['[:,]'])

  class { 'gid_shadow::change_gid':
    file_input => $file_input5
  }
}