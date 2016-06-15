define unrealirc::config::vhost(
  $vhost,
  $login,
  $password,
  $password_auth_type = undef,
  $userhosts = ['*@*'],
  $swhois = undef,
)
{
  file { "${unrealirc::install_path}/config/vhost_${name}.conf":
    ensure   => file,
    mode     => '0600',
    owner    => $unrealirc::user,
    group    => $unrealirc::group,
    content  => template('unrealirc/config/vhost.conf.erb'),
    require  => File['unrealirc_config_directory'],
  }
}