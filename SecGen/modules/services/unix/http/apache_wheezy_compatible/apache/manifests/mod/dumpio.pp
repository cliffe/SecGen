class apache::mod::dumpio(
  $dump_io_input  = 'Off',
  $dump_io_output = 'Off',
) {
  include ::apache
  validate_re(downcase($dump_io_input), '^(on|off)$', "${dump_io_input} is not supported for dump_io_input.  Allowed values are 'On' and 'Off'.")
  validate_re(downcase($dump_io_output), '^(on|off)$', "${dump_io_output} is not supported for dump_io_output.  Allowed values are 'On' and 'Off'.")

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
