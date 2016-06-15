# Options is an array and can contain useip|noident|ssl|nopasscont
define unrealirc_3281_backdoor::config::allow(
  $ip = '*@*',
  $hostname = '*@*',
  $class = 'clients',
  $password = undef,
  $password_auth_type = undef,
  $maxperip = undef,
  $ipv6_clone_mask = undef,
  $redirect_server = undef,
  $redirect_port = undef,
  $options = undef,
)
{
  file { "${unrealirc_3281_backdoor::install_path}/config/allow_${name}.conf":
    ensure   => file,
    mode     => '0600',
    owner    => $unrealirc_3281_backdoor::user,
    group    => $unrealirc_3281_backdoor::group,
    content  => template('unrealirc_3281_backdoor/config/allow.conf.erb'),
    require  => File['unrealirc_config_directory'],
  }
}