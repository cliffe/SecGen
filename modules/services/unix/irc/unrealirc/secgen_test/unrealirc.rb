require_relative '../../../../../lib/post_provision_test'

class UnrealircTest < PostProvisionTest
  INSTALL = '/var/lib/unreal'

  def initialize
    self.module_name = 'unrealirc'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super
    ip = self.json_inputs['ip']&.first
    # Address to connect to from inside the guest: the configured listen
    # address, or loopback when it listens on every interface ('*').
    connect_ip = (ip.nil? || ip == '*' || ip.empty?) ? '127.0.0.1' : ip

    tier(1) do
      test_local_command('irc user exists', 'id irc', 'irc')
      test_local_command('ircd built', "test -x #{INSTALL}/src/ircd && echo ok", 'ok')
      test_local_command('install owned by irc', "stat -c %U #{INSTALL}/unrealircd.conf", 'irc')
      test_local_command('unrealircd.conf deployed', "cat #{INSTALL}/unrealircd.conf", 'me {')
      test_local_command('motd deployed', "test -s #{INSTALL}/ircd.motd && echo ok", 'ok')
      test_local_command('log file created', 'test -f /var/log/ircd.log && echo ok', 'ok')
      test_local_command('init script installed', 'test -x /etc/init.d/unreal && echo ok', 'ok')
      test_local_command('build dependencies present', 'dpkg -s build-essential libssl-dev libcurl4-openssl-dev', 'Status: install ok installed')
      test_local_command('daemon process running as irc', 'ps -eo user,args | grep [s]rc/ircd', 'irc')
      # the listen block is rendered from the ip and port inputs
      if (port = self.json_inputs['port']&.first)
        listen_ip = ip.nil? || ip.empty? ? '*' : ip
        test_local_command('listen block uses ip and port', "cat #{INSTALL}/config/listen_*.conf", "listen #{listen_ip}:#{port}")
      end
    end
    tier(2) do
      test_service_up
      # a client can register and gets the welcome numeric from the daemon
      test_local_command('IRC registration welcomed',
                         %Q(timeout 10 bash -c 'exec 3<>/dev/tcp/#{connect_ip}/#{self.port}; printf "NICK secgen\\r\\nUSER secgen 0 * :secgen\\r\\n" >&3; timeout 3 cat <&3' 2>/dev/null | head -c 2000),
                         ' 001 ')
    end
  end
end

UnrealircTest.new.run
