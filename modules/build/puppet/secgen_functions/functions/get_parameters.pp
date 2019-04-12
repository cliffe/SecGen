function secgen_functions::get_parameters($base64_inputs_file) {
  $b64_inputs = file("secgen_functions/json_inputs/$base64_inputs_file")
  $json_inputs = base64('decode', $b64_inputs)
  $secgen_parameters = parsejson($json_inputs)
  $secgen_parameters
}
