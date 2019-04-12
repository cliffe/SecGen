# Options is array and can contain 'ssl'
define unrealirc::config::tld(
    $mask,
    $motd = undef,
    $shortmotd = undef,
    $opermotd = undef,
    $svsmotd = undef,
    $botmotd = undef,
    $channel = undef,
    $options = undef,
)
{
  file { "${unrealirc::install_path}/config/tld_${name}.conf":
    ensure   => file,
    mode     => '0600',
    owner    => $unrealirc::user,
    group    => $unrealirc::group,
    content  => template('unrealirc/config/tld.conf.erb'),
    require  => File['unrealirc_config_directory'],
  }
}