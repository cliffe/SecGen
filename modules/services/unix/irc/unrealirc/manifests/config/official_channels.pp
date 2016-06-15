# Channels is an array containing for each element 'name' and 'topic'

define unrealirc::config::official_channels (
  $channels = [],
)
{
  file { "${unrealirc::install_path}/config/officialchannels.conf":
    ensure   => file,
    mode     => '0600',
    owner    => $unrealirc::user,
    group    => $unrealirc::group,
    content  => template('unrealirc/config/official_channels.conf.erb'),
    require  => File['unrealirc_config_directory'],
  }
}