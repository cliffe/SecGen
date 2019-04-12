class augeas::install{
  package { ['augeas-tools']:
    ensure => 'installed',
  }
}
