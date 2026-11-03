class hash_tools::install{
  # hashdeep ships the md5deep/sha*deep commands on every base. md5deep is only a
  # transitional package (dropped from kali-rolling), so install the real package everywhere.
  package { ['hashdeep']:
    ensure => 'installed',
  }
  case $operatingsystem {
    'Debian': {
      package { ['debsums']:
        ensure => 'installed',
      }
    }
  }
}
