$json_inputs = base64('decode', $::base64_inputs)
$secgen_parameters=parsejson($json_inputs)
$creation_time_file_path=$secgen_parameters['creation_time_file_path'][0]
$creation_time_date=$secgen_parameters['creation_time_date'][0]

file { 'ensure_path_present':
  path => $creation_time_file_path,
  ensure => 'present'
}

class { 'change_timestamp_creation_time':
  file_path => $creation_time_file_path,
  file_time => $creation_time_date
}