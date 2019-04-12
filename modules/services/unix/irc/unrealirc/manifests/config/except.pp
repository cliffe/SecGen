# Type is ban|tkl|throttle
# Types is an array which can contains gline|gzline|qline|gqline|shun|all and only for "tkl" type

define unrealirc::config::except (
  $type,
  $mask,
  $types = undef,
)
{
  if $types and $type != 'tkl' {
    fail("'types' option must only be specified for 'tkl' except type")
  }

  file { "${unrealirc::install_path}/config/except_${name}.conf":
    ensure   => file,
    mode     => '0600',
    owner    => $unrealirc::user,
    group    => $unrealirc::group,
    content  => template('unrealirc/config/except.conf.erb'),
    require  => File['unrealirc_config_directory'],
  }
}