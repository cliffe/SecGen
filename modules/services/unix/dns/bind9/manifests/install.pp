class bind9::install {
  # bind9-dnsutils provides dig, used by the secgen_test and by students
  package { ['bind9', 'bind9-dnsutils']:
    ensure => installed,
  }
}
