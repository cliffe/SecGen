class create_directory ($directory_path) {
  file { 'create_directory':
    path => $directory_path,
    ensure => 'directory',
  }
}