class fingerd::install {
  # fingerd needs an inetd to run under, and runs the finger client to answer.
  package { ['openbsd-inetd', 'finger', 'fingerd']:
    ensure => 'installed',
  }
}
