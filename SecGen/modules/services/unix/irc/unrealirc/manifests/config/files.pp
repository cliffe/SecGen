define unrealirc::config::files(
    $motd = undef,
    $shortmotd = undef,
    $opermotd = undef,
    $svsmotd = undef,
    $botmotd = undef,
    $rules = undef,
    $tunefile = undef,
    $pidfile = $unrealirc::pidfile,
)
{
  file { "${unrealirc::install_path}/config/files.conf":
    ensure   => file,
    mode     => '0600',
    owner    => $unrealirc::user,
    group    => $unrealirc::group,
    content  => template('unrealirc/config/files.conf.erb'),
    require  => File['unrealirc_config_directory'],
  }
}