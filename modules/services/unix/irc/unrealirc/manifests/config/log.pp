define unrealirc::config::log(
  $log_path = "${unrealirc::log_path}",
  $maxsize = 2097152,
  $flags = ['errors'],
)
{
  file { "${unrealirc::install_path}/config/log.conf":
    ensure   => file,
    mode     => '0600',
    owner    => $unrealirc::user,
    group    => $unrealirc::group,
    content  => template('unrealirc/config/log.conf.erb'),
    require  => File['unrealirc_config_directory'],
  }
}