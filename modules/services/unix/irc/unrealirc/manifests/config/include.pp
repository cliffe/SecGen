define unrealirc::config::include (
  $file,
)
{
  file { "${unrealirc::install_path}/config/include_${name}.conf":
    ensure   => file,
    mode     => '0600',
    owner    => $unrealirc::user,
    group    => $unrealirc::group,
    content  => template('unrealirc/config/include.conf.erb'),
    require  => File['unrealirc_config_directory'],
  }
}