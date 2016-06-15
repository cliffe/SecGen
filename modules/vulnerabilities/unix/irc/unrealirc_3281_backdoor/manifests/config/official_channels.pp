# Channels is an array containing for each element 'name' and 'topic'

define unrealirc_3281_backdoor::config::official_channels (
  $channels = [],
)
{
  file { "${unrealirc_3281_backdoor::install_path}/config/officialchannels.conf":
    ensure   => file,
    mode     => '0600',
    owner    => $unrealirc_3281_backdoor::user,
    group    => $unrealirc_3281_backdoor::group,
    content  => template('unrealirc_3281_backdoor/config/official_channels.conf.erb'),
    require  => File['unrealirc_config_directory'],
  }
}