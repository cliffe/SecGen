class weechat::install{
  package { 'weechat':
    ensure => 'installed',
  }
}
