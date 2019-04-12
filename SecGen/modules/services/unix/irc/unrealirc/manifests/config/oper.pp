define unrealirc::config::oper(
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
  file { "${unrealirc::install_path}/config/oper_${name}.conf":
    ensure   => file,
    mode     => '0600',
    owner    => $unrealirc::user,
    group    => $unrealirc::group,
    content  => template('unrealirc/config/oper.conf.erb'),
    require  => File['unrealirc_config_directory'],
  }
}