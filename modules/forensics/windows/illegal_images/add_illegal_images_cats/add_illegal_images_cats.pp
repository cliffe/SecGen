$json_inputs = base64('decode', $::base64_inputs)
$secgen_parameters=parsejson($json_inputs)
$image_path=$secgen_parameters['image_path'][0]
$original_image_filename=$secgen_parameters['original_image_filename'][0]

class { 'add_illegal_images_cats':
  image_path => $image_path,
  image_binary => $original_image_filename
}

# $image_binary = base64('decode', $image_binary)

# file { 'add_cat_image':
#   path => "$image_path",
#   ensure => 'file',
#   # content => $image_binary,
#   # content => base64('decode', $image_binary),
#   # source => '/media/user/3TB_internal_drive/Documents/SecGen/lib/resources/internet_browser_files/chrome_history_file.source',
#   # source => 'puppet:///modules/add_illegal_images_cats/chrome_history_file.source'
#   source => "puppet:///modules/file_transfer_storage_module/$original_image_filename"
# }