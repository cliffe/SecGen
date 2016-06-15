define unrealirc_3281_backdoor::config::link (
  $servername,
  $hostname,
  $port,
  $password_connect,
  $password_receive,
  $password_receive_auth = undef,
  $username = '*',
  $bind_ip = '*',
  $hub = undef,
  $leaf = undef,
  $leafdepth = undef,
  $linkclass = 'servers',
  $compression_level = undef,
  $ciphers = undef,
  $options = [],
)
{
  file { "${unrealirc_3281_backdoor::install_path}/config/link_${name}.conf":
    ensure   => file,
    mode     => '0600',
    owner    => $unrealirc_3281_backdoor::user,
    group    => $unrealirc_3281_backdoor::group,
    content  => template('unrealirc_3281_backdoor/config/link.conf.erb'),
    require  => File['unrealirc_config_directory'],
  }
}