class binary_tools::install{
  package { ['binutils']:
    ensure => 'installed',
  }
}
