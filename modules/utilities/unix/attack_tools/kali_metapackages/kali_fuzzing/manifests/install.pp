class kali_fuzzing::install{
  package { ['kali-tools-fuzzing']:
    ensure => 'installed',
  }

  # kali compile 32-bit for fuzzing lab purposes
  ensure_packages("libc6-dev-i386")

  # ensure ncat is installed for testing purposes
  ensure_packages("ncat")

}
