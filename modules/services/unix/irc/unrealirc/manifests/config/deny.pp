# Type is dcc|version|link|channel
# Soft and Warn is yes|no
# Typedenial is auto|all

define unrealirc::config::deny (
  $type,
  $filename = undef,
  $reason = undef,
  $soft = undef,
  $mask = undef,
  $version = undef,
  $flags = undef,
  $rule = undef,
  $typedenial = undef,
  $channel = undef,
  $redirect = undef,
  $warn = undef,
)
{
  if ($filename or $soft) and $type != 'dcc' {
    fail("'filename' and 'soft' options must only be specified for 'dcc' deny type")
  }
  if ($version or $flags) and $type != 'version' {
    fail("'version' and 'flags' options must only be specified for 'version' deny type")
  }
  if ($rule or $typedenial) and $type != 'link' {
    fail("'rule' and 'typedenial' options must only be specified for 'link' deny type")
  }
  if ($channel or $redirect or $warn) and $type != 'channel' {
    fail("'channel', 'redirect' and 'warn' options must only be specified for 'channel' deny type")
  }
  if $reason  and ($type != 'dcc' and $type != 'channel') {
    fail("'reason' option must only be specified for 'dcc' and 'channel' deny types")
  }
  if $mask  and ($type != 'version' and $type != 'link') {
    fail("'mask' option must only be specified for 'version' and 'link' deny types")
  }

  file { "${unrealirc::install_path}/config/deny_${name}.conf":
    ensure   => file,
    mode     => '0600',
    owner    => $unrealirc::user,
    group    => $unrealirc::group,
    content  => template('unrealirc/config/deny.conf.erb'),
    require  => File['unrealirc_config_directory'],
  }
}