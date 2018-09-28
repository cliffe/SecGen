$json_inputs = base64('decode', $::base64_inputs)
$secgen_parameters=parsejson($json_inputs)
$prefetch_file_name=$secgen_parameters['prefetch_file_name']

class { 'insert_prefetch_file':
  prefetch_file_name => $prefetch_file_name[0],
}