class snort::install{
  package { ['snort']:
    ensure => 'installed',
  }
}
