class place_prefetch_files ($prefetch_files) {
  file { $prefetch_files:
    path => $prefetch_files
  }
}