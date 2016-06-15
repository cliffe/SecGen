# Type is services|stats|normal|channel|command
# Format is an array containing regex|target|type|parameters|command only when type is "command"
# Format Type is services|stats|normal|channel|command|real
define unrealirc::config::alias(
  $aliasname,
  $type,
  $target = undef,
  $spamfilter = undef,
  $formats = undef,
)
{
  if $formats and $type != 'command' {
    fail("'formats' option must only be specified for 'command' alias type")
  }

  file { "${unrealirc::install_path}/config/alias_${name}.conf":
    ensure   => file,
    mode     => '0600',
    owner    => $unrealirc::user,
    group    => $unrealirc::group,
    content  => template('unrealirc/config/alias.conf.erb'),
    require  => File['unrealirc_config_directory'],
  }
}