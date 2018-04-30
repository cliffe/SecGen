class unrealirc(
  $install_path = '/var/lib/unreal',
  $user = 'irc',
  $group = 'irc',
  $log_path = '/var/log/ircd.log',
  $servername = 'irc.myserver.org',
  $serverdesc = 'Description of irc server',
  $maxusers = 100,
  $maxservers = 10,
  $admins = ['admin <admin@myserver.org>'],
  $pidfile = '/var/lib/unreal/ircd.pid',
  $filename = 'Unreal3.2.8.1',
  $use_ssl = false,
  $ssl_cert = undef,
  $ssl_key = undef,
  $motd = undef
) {
  $secgen_inputs = secgen_functions::get_parameters($::base64_inputs_file)
  $ip = $secgen_inputs['ip'][0]
  $port = $secgen_inputs['port'][0]

  class { '::unrealirc::vulnerabilities': } ->
  class { '::unrealirc::install': } ->
  class { '::unrealirc::config': } ~>
  class { '::unrealirc::service': }

    unrealirc::config::set { 'network':
      network_name        =>  "Public Name of My Server",
      default_server      =>  "irc.myserver.org",
      services_server     =>  "services.myserver.org",
      kline_address       =>  "contact@myserver.org",
      maxchannelsperuser  =>  100,
      hosts_global        => "",
      hosts_admin         => "",
      hosts_netadmin      => "",
      hosts_servicesadmin => "",
      hosts_coadmin       => "",
      help_channel        => "#help",
      hiddenhost_prefix   => "+x",
      cloak_keys_1        => "NGDJMSKFLa24",
      cloak_keys_2        => "ax9d2ujrjRQA",
      cloak_keys_3        => "ax9d25524ZSx"
    }

    unrealirc::config::listen { 'default_6667':
      ip => $ip,
      port => $port,
    }

    unrealirc::config::log { 'default':
      flags =>  ['oper','kline','connects','server-connects','kills','errors','sadmin-commands','chg-commands','oper-override','spamfilter'],
    }
}