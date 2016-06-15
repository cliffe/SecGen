# Type is nick|user|ip|version|server|realname
# Action is kill|tempshun|shun|kline|zline|gline|gzline and only for "version" type

define unrealirc::config::ban (
  $type,
  $mask,
  $reason,
  $action = undef,
)
{
  if $action and $type != 'version' {
    fail("'action' option must only be specified for 'version' ban type")
  }

  file { "${unrealirc::install_path}/config/ban_${name}.conf":
    ensure   => file,
    mode     => '0600',
    owner    => $unrealirc::user,
    group    => $unrealirc::group,
    content  => template('unrealirc/config/ban.conf.erb'),
    require  => File['unrealirc_config_directory'],
  }
}