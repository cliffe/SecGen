# Type is ban|tkl|throttle
# Types is an array which can contains gline|gzline|qline|gqline|shun|all and only for "tkl" type

define unrealirc_3281_backdoor::config::except (
  $type,
  $mask,
  $types = undef,
)
{
  if $types and $type != 'tkl' {
    fail("'types' option must only be specified for 'tkl' except type")
  }

  file { "${unrealirc_3281_backdoor::install_path}/config/except_${name}.conf":
    ensure   => file,
    mode     => '0600',
    owner    => $unrealirc_3281_backdoor::user,
    group    => $unrealirc_3281_backdoor::group,
    content  => template('unrealirc_3281_backdoor/config/except.conf.erb'),
    require  => File['unrealirc_config_directory'],
  }
}