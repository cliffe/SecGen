class armitage::install{
  package { ['armitage']:
    ensure => 'installed',
  }
}
