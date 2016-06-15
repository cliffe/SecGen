define unrealirc_3281_backdoor::config::vhost(
  $vhost,
  $login,
  $password,
  $password_auth_type = undef,
  $userhosts = ['*@*'],
  $swhois = undef,
)
{
  file { "${unrealirc_3281_backdoor::install_path}/config/vhost_${name}.conf":
    ensure   => file,
    mode     => '0600',
    owner    => $unrealirc_3281_backdoor::user,
    group    => $unrealirc_3281_backdoor::group,
    content  => template('unrealirc_3281_backdoor/config/vhost.conf.erb'),
    require  => File['unrealirc_config_directory'],
  }
}