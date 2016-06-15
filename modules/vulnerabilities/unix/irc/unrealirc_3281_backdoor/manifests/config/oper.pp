define unrealirc_3281_backdoor::config::oper(
  $username,
  $password,
  $operclass = 'clients',
  $flags = ['local'],
  $password_auth_type = undef,
  $userhosts = ['*@*'],
  $require_modes = undef,
  $swhois = undef,
  $snomask = undef,
  $modes = undef,
  $maxlogins = undef,
)
{
  file { "${unrealirc_3281_backdoor::install_path}/config/oper_${name}.conf":
    ensure   => file,
    mode     => '0600',
    owner    => $unrealirc_3281_backdoor::user,
    group    => $unrealirc_3281_backdoor::group,
    content  => template('unrealirc_3281_backdoor/config/oper.conf.erb'),
    require  => File['unrealirc_config_directory'],
  }
}