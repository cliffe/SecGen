# Options is array and can contain 'ssl'
define unrealirc_3281_backdoor::config::tld(
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
  file { "${unrealirc_3281_backdoor::install_path}/config/tld_${name}.conf":
    ensure   => file,
    mode     => '0600',
    owner    => $unrealirc_3281_backdoor::user,
    group    => $unrealirc_3281_backdoor::group,
    content  => template('unrealirc_3281_backdoor/config/tld.conf.erb'),
    require  => File['unrealirc_config_directory'],
  }
}