# Options is an array and can contain useip|noident|ssl|nopasscont
define unrealirc::config::allow(
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
  file { "${unrealirc::install_path}/config/allow_${name}.conf":
    ensure   => file,
    mode     => '0600',
    owner    => $unrealirc::user,
    group    => $unrealirc::group,
    content  => template('unrealirc/config/allow.conf.erb'),
    require  => File['unrealirc_config_directory'],
  }
}