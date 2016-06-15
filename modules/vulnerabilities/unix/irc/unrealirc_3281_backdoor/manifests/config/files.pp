define unrealirc_3281_backdoor::config::files(
    $motd = undef,
    $shortmotd = undef,
    $opermotd = undef,
    $svsmotd = undef,
    $botmotd = undef,
    $rules = undef,
    $tunefile = undef,
    $pidfile = $unrealirc_3281_backdoor::pidfile,
)
{
  file { "${unrealirc_3281_backdoor::install_path}/config/files.conf":
    ensure   => file,
    mode     => '0600',
    owner    => $unrealirc_3281_backdoor::user,
    group    => $unrealirc_3281_backdoor::group,
    content  => template('unrealirc_3281_backdoor/config/files.conf.erb'),
    require  => File['unrealirc_config_directory'],
  }
}