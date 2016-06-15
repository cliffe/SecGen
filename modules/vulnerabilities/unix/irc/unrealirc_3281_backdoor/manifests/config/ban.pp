# Type is nick|user|ip|version|server|realname
# Action is kill|tempshun|shun|kline|zline|gline|gzline and only for "version" type

define unrealirc_3281_backdoor::config::ban (
  $type,
  $mask,
  $reason,
  $action = undef,
)
{
  if $action and $type != 'version' {
    fail("'action' option must only be specified for 'version' ban type")
  }

  file { "${unrealirc_3281_backdoor::install_path}/config/ban_${name}.conf":
    ensure   => file,
    mode     => '0600',
    owner    => $unrealirc_3281_backdoor::user,
    group    => $unrealirc_3281_backdoor::group,
    content  => template('unrealirc_3281_backdoor/config/ban.conf.erb'),
    require  => File['unrealirc_config_directory'],
  }
}