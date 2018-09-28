class create_file ($file_path, $file_contents) {
  file { 'create_file':
    path => $file_path,
    ensure => 'file',
    content => $file_contents,
  }
}