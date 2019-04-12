# Options is an array and can contain clientsonly|serversonly|java|ssl
define unrealirc::config::listen (
  $port,
  $ip = '*',
  $options = undef,
)
{
  file { "${unrealirc::install_path}/config/listen_${name}.conf":
    ensure   => file,
    mode     => '0600',
    owner    => $unrealirc::user,
    group    => $unrealirc::group,
    content  => template('unrealirc/config/listen.conf.erb'),
    notify   => Service['unreal'],
    require  => File['unrealirc_config_directory'],
  }
}