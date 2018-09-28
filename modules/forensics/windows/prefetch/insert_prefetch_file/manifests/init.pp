class insert_prefetch_file ($prefetch_file_name) {
  file { 'ensure_prefetch_directory_exists_test':
    path => "$system32\\Prefetch",
    ensure => directory,
  }

  file { 'add_prefetch_file':
    path => "$system32\\Prefetch\\$prefetch_file_name",
    ensure => 'file',
    source => "puppet:///modules/file_transfer_storage_module/$prefetch_file_name",
    source_permissions => ignore,
  }
}