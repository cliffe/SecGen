require_relative '../../../../../lib/post_provision_test'

class ErgochatTest < PostProvisionTest
  def initialize
    self.module_name = 'ergochat'
    self.module_path = get_module_path(__FILE__)
    super
    self.port = 6667 # module has no port input; the listener is fixed in files/ircd.yaml
  end

  def test_module
    super
    # No read_facts or default_inputs: nothing parameterised to check.
    tier(1) do
      test_local_command('ergo binary installed', '/usr/local/bin/ergo --version', 'ergo')
      test_local_command('ergochat user exists', 'id ergochat', 'ergochat')
      test_local_command('config deployed, group-readable only', 'stat -c "%U:%G %a" /etc/ergochat/ircd.yaml', 'root:ergochat 640')
      test_local_command('motd installed', 'test -s /etc/ergochat/ergo.motd && echo ok', 'ok')
      test_local_command('languages installed', 'ls /usr/share/ergochat/languages', '.lang')
      test_local_command('datastore owned by ergochat', 'stat -c %U /var/lib/ergochat/ircd.db', 'ergochat')
      test_local_command('systemd unit installed', 'cat /etc/systemd/system/ergochat.service', 'ExecStart=/usr/local/bin/ergo run')
      test_local_command('service enabled', 'systemctl is-enabled ergochat', 'enabled')
      test_local_command('service active', 'systemctl is-active ergochat | grep -x active', 'active')
    end
    tier(2) do
      test_service_up
      # WebSocket listener used by the browser hackerbot client
      test_service_up(port: 8097)
      # the tool runs as the service account
      test_local_command('ergo runs as ergochat', '/usr/local/bin/ergo --version', 'ergo', user: 'ergochat')
      # a client can register and gets the welcome numeric from the configured server name
      test_local_command('IRC registration welcomed',
                         %q(timeout 10 bash -c 'exec 3<>/dev/tcp/127.0.0.1/6667; printf "NICK secgen\r\nUSER secgen 0 * :secgen\r\n" >&3; timeout 3 cat <&3' 2>/dev/null | head -c 2000),
                         ':irc.localhost 001', tier: 2)
    end
  end
end

ErgochatTest.new.run
