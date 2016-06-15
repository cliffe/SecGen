# Type is channel|dcc
# Soft is yes|no

define unrealirc_3281_backdoor::config::allowtype (
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

  file { "${unrealirc_3281_backdoor::install_path}/config/allowtype_${name}.conf":
    ensure   => file,
    mode     => '0600',
    owner    => $unrealirc_3281_backdoor::user,
    group    => $unrealirc_3281_backdoor::group,
    content  => template('unrealirc_3281_backdoor/config/allowtype.conf.erb'),
    require  => File['unrealirc_config_directory'],
  }
}