# Options is an array and can contain clientsonly|serversonly|java|ssl
define unrealirc_3281_backdoor::config::listen (
  $port,
  $ip = '*',
  $options = undef,
)
{
  file { "${unrealirc_3281_backdoor::install_path}/config/listen_${name}.conf":
    ensure   => file,
    mode     => '0600',
    owner    => $unrealirc_3281_backdoor::user,
    group    => $unrealirc_3281_backdoor::group,
    content  => template('unrealirc_3281_backdoor/config/listen.conf.erb'),
    require  => File['unrealirc_config_directory'],
  }
}