define unrealirc_3281_backdoor::config::log(
  $log_path = "${unrealirc_3281_backdoor::log_path}",
  $maxsize = 2097152,
  $flags = ['errors'],
)
{
  file { "${unrealirc_3281_backdoor::install_path}/config/log.conf":
    ensure   => file,
    mode     => '0600',
    owner    => $unrealirc_3281_backdoor::user,
    group    => $unrealirc_3281_backdoor::group,
    content  => template('unrealirc_3281_backdoor/config/log.conf.erb'),
    require  => File['unrealirc_config_directory'],
  }
}