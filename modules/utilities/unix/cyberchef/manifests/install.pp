class cyberchef::install {
  # cyberchef_www includes modules/*.js, which the app's worker loads at runtime
  file {
   '/opt/cyberchef':
    ensure => 'directory',
    source => 'puppet:///modules/cyberchef/cyberchef_www',
    recurse => 'remote',
    mode  => '0744', # Use 0700 if it is sensitive
  }

}
