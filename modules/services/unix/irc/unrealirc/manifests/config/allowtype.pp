# Type is channel|dcc
# Soft is yes|no

define unrealirc::config::allowtype (
  $type,
  $filename = undef,
  $soft = undef,
  $channel = undef,
)
{
  if ($filename or $soft) and $type != 'dcc' {
    fail("'filename' and 'soft' options must only be specified for 'dcc' allow type")
  }
  if $channel and $type != 'channel' {
    fail("'channel' option must only be specified for 'channel' allow type")
  }

  file { "${unrealirc::install_path}/config/allowtype_${name}.conf":
    ensure   => file,
    mode     => '0600',
    owner    => $unrealirc::user,
    group    => $unrealirc::group,
    content  => template('unrealirc/config/allowtype.conf.erb'),
    require  => File['unrealirc_config_directory'],
  }
}