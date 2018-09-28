$json_inputs = base64('decode', $::base64_inputs)
$secgen_parameters=parsejson($json_inputs)
$key_locations=$secgen_parameters['key_locations']

class { 'add_registry_keys':
  key_locations => $key_locations[0],
}