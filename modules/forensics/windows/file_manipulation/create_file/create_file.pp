$json_inputs = base64('decode', $::base64_inputs)
$secgen_parameters=parsejson($json_inputs)
$new_file_path=$secgen_parameters['new_file_path'][0]
$new_file_contents=$secgen_parameters['new_file_contents'][0]

class { 'create_file':
  file_path => $new_file_path,
  file_contents => $new_file_contents
}