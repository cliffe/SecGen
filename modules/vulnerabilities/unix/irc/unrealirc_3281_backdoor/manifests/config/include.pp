define unrealirc_3281_backdoor::config::include (
  $file,
)
{
  file { "${unrealirc_3281_backdoor::install_path}/config/include_${name}.conf":
    ensure   => file,
    mode     => '0600',
    owner    => $unrealirc_3281_backdoor::user,
    group    => $unrealirc_3281_backdoor::group,
    content  => template('unrealirc_3281_backdoor/config/include.conf.erb'),
    require  => File['unrealirc_config_directory'],
  }
}