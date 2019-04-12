class gnome::install{
  case $operatingsystem {
    'Debian': {
      package { ['task-gnome-desktop']:
        ensure => 'installed',
      }
    }
  }
}
