class apache::mod::dumpio(
  Enum['Off', 'On', 'off', 'on'] $dump_io_input  = 'Off',
  Enum['Off', 'On', 'off', 'on'] $dump_io_output = 'Off',
) {
  include ::apache

  ::apache::mod { 'dumpio': }
  file{'dumpio.conf':
    ensure  => file,
    path    => "${::apache::mod_dir}/dumpio.conf",
    mode    => $::apache::file_mode,
    content => template('apache/mod/dumpio.conf.erb'),
    require => Exec["mkdir ${::apache::mod_dir}"],
    before  => File[$::apache::mod_dir],
    notify  => Class['apache::service'],
  }

}
