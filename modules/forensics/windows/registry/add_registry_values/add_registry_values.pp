$json_inputs = base64('decode', $::base64_inputs)
$secgen_parameters=parsejson($json_inputs)
$key_locations=$secgen_parameters['key_locations']
$key_value_type=$secgen_parameters['key_value_type']
$key_value=$secgen_parameters['key_value']

class { 'add_registry_values':
  key_location => $key_locations[0],
  key_value_type => $key_value_type[0],
  key_value => $key_value[0],
}