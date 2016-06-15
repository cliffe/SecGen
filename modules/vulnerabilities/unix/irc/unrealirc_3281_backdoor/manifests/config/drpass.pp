define unrealirc_3281_backdoor::config::drpass(
  $restart = undef,
  $restart_auth = undef,
  $die = undef,
  $die_auth = undef,
)
{
  file { "${unrealirc_3281_backdoor::install_path}/config/drpass.conf":
    ensure   => file,
    mode     => '0600',
    owner    => $unrealirc_3281_backdoor::user,
    group    => $unrealirc_3281_backdoor::group,
    content  => template('unrealirc_3281_backdoor/config/drpass.conf.erb'),
    require  => File['unrealirc_config_directory'],
  }
}