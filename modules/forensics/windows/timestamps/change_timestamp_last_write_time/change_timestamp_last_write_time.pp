$json_inputs = base64('decode', $::base64_inputs)
$secgen_parameters=parsejson($json_inputs)
$last_write_time_file_path=$secgen_parameters['last_write_time_file_path'][0]
$last_write_time_date=$secgen_parameters['last_write_time_date'][0]

file { 'ensure_path_present':
  path => $last_write_time_file_path,
  ensure => 'present'
}

class { 'change_timestamp_last_write_time':
  file_path => $last_write_time_file_path,
  file_time => $last_write_time_date
}