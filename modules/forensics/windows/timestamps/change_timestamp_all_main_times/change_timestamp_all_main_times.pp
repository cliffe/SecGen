$json_inputs = base64('decode', $::base64_inputs)
$secgen_parameters=parsejson($json_inputs)
$all_times_file_path=$secgen_parameters['all_times_file_path'][0]
$all_times_date=$secgen_parameters['all_times_date'][0]

file { 'ensure_path_present':
  path => $all_times_file_path,
  ensure => 'present'
}

class { 'change_timestamp_all_main_times':
  file_path => $all_times_file_path,
  file_time => $all_times_date
}