class kde_minimal::install{
  case $operatingsystem {
    'Debian': {
      package { ['kde-plasma-desktop', 'kate', 'ksnapshot', 'qtcurve']:
        ensure => 'installed',
      }
    }
  }
}
