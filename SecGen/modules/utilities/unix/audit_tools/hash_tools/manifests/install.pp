class hash_tools::install{
  package { ['md5deep']:
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
