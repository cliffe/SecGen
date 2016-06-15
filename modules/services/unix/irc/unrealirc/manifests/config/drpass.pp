define unrealirc::config::drpass(
  $restart = undef,
  $restart_auth = undef,
  $die = undef,
  $die_auth = undef,
)
{
  file { "${unrealirc::install_path}/config/drpass.conf":
    ensure   => file,
    mode     => '0600',
    owner    => $unrealirc::user,
    group    => $unrealirc::group,
    content  => template('unrealirc/config/drpass.conf.erb'),
    require  => File['unrealirc_config_directory'],
  }
}