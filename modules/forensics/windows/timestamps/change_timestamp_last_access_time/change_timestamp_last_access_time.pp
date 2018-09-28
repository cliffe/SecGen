$json_inputs = base64('decode', $::base64_inputs)
$secgen_parameters=parsejson($json_inputs)
$last_access_time_file_path=$secgen_parameters['last_access_time_file_path'][0]
$last_access_time_date=$secgen_parameters['last_access_time_date'][0]

file { 'ensure_path_present':
  path => $last_access_time_file_path,
  ensure => 'present'
}

class { 'change_timestamp_last_access_time':
  file_path => $last_access_time_file_path,
  file_time => $last_access_time_date
}