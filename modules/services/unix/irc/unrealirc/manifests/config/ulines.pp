define unrealirc::config::ulines (
  $servers = [],
)
{
  file { "${unrealirc::install_path}/config/ulines_${name}.conf":
    ensure   => file,
    mode     => '0600',
    owner    => $unrealirc::user,
    group    => $unrealirc::group,
    content  => template('unrealirc/config/ulines.conf.erb'),
    require  => File['unrealirc_config_directory'],
  }
}