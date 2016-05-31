class apache::mod::alias(
  $apache_version = $apache::apache_version,
  $icons_options  = 'Indexes MultiViews',
  # set icons_path to false to disable the alias
  $icons_path     = $::apache::params::alias_icons_path,

) {
  apache::mod { 'alias': }
  # Template uses $icons_path
  if $icons_path {
    file { 'alias.conf':
      ensure  => file,
      path    => "${::apache::mod_dir}/alias.conf",
      content => template('apache/mod/alias.conf.erb'),
      require => Exec["mkdir ${::apache::mod_dir}"],
      before  => File[$::apache::mod_dir],
      notify  => Class['apache::service'],
    }
  }
}
