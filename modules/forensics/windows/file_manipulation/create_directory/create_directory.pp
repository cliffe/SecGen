$json_inputs = base64('decode', $::base64_inputs)
$secgen_parameters=parsejson($json_inputs)
$new_directory_path=$secgen_parameters['new_directory_path'][0]

class { 'create_directory':
  directory_path => $new_directory_path,
}