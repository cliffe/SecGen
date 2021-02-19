class git::install {
  package { 'git':
    ensure => installed,
  }
}
