class add_illegal_images_cats ($image_path, $image_binary) {
  file { 'add_cat_image':
    path => "$image_path",
    ensure => 'file',
    # content => $image_binary,
    # content => base64('decode', $image_binary),
    # source => '/media/user/3TB_internal_drive/Documents/SecGen/lib/resources/internet_browser_files/chrome_history_file.source',
    # source => 'puppet:///modules/add_illegal_images_cats/chrome_history_file.source'
    source => "puppet:///modules/file_transfer_storage_module/$original_image_filename"
  }
}