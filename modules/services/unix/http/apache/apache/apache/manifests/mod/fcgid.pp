class apache::mod::fcgid(
  $options = {},
) {

  ::apache::mod { 'fcgid':
    loadfile_name => 'unixd_fcgid.load',
  }

  # Template uses:
  # - $options
  file { 'unixd_fcgid.conf':
    ensure  => file,
    path    => "${::apache::mod_dir}/unixd_fcgid.conf",
    content => template('apache/mod/unixd_fcgid.conf.erb'),
    require => Exec["mkdir ${::apache::mod_dir}"],
    before  => File[$::apache::mod_dir],
    notify  => Class['apache::service'],
  }
}
