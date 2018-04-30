class apache::mod::fcgid(
  $options = {},
) {
  include ::apache
  if ($::osfamily == 'RedHat' and $::operatingsystemmajrelease == '7') or $::osfamily == 'FreeBSD' {
    $loadfile_name = 'unixd_fcgid.load'
    $conf_name = 'unixd_fcgid.conf'
  } else {
    $loadfile_name = undef
    $conf_name = 'fcgid.conf'
  }

  ::apache::mod { 'fcgid':
    loadfile_name => $loadfile_name,
  }

  # Template uses:
  # - $options
  file { $conf_name:
    ensure  => file,
    path    => "${::apache::mod_dir}/${conf_name}",
    mode    => $::apache::file_mode,
    content => template('apache/mod/fcgid.conf.erb'),
    require => Exec["mkdir ${::apache::mod_dir}"],
    before  => File[$::apache::mod_dir],
    notify  => Class['apache::service'],
  }
}
