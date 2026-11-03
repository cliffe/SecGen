class kde_minimal::install{
  case $operatingsystem {
    'Debian': {
      # ksnapshot was removed after Debian 10 (buster); spectacle is its KDE Plasma 5 replacement.
      # Debian 11 and 12 package it as kde-spectacle; the name became spectacle in Debian 13.
      if versioncmp($facts['os']['release']['major'], '13') >= 0 {
        $screenshot_tool = 'spectacle'
      } elsif versioncmp($facts['os']['release']['major'], '11') >= 0 {
        $screenshot_tool = 'kde-spectacle'
      } else {
        $screenshot_tool = 'ksnapshot'
      }
      package { ['kde-plasma-desktop', 'kate', $screenshot_tool, 'qtcurve']:
        ensure => 'installed',
      }
    }
  }
}
