require_relative '../../../../../lib/post_provision_test'

class OpenvpnServerTest < PostProvisionTest
  def initialize
    self.module_name = 'openvpn_server'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super
    pki = begin
      JSON.parse(self.json_inputs['openvpn_pki'].first)
    rescue StandardError
      {}
    end
    start_on_boot = self.json_inputs['start_on_boot']&.first
    # openvpn_pki is a JSON bundle; server_ip and push_routes are checked in server.conf
    # below. The listening port comes from its 'port' key (UDP), not a 'port' input.
    udp_port = pki['port']
    dir = '/etc/openvpn/server'

    tier(1) do
      test_local_command('openvpn installed?', 'dpkg -l openvpn | grep -E "^ii"', 'openvpn')
      test_local_command('PKI and config files present?',
                         "cd #{dir} && test -s ca.crt && test -s server.crt && test -s server.key && test -s dh.pem && test -s server.conf && echo ok",
                         'ok')
      test_local_command('openvpn on PATH', 'which openvpn', 'openvpn')
      test_local_command('server directory is root-only', "stat -c '%U:%G %a' #{dir}", 'root:root 750')
      test_local_command('server.key is root-only?', "stat -c %a #{dir}/server.key", '600')
      # the PKI material written to disk is the material supplied
      { 'ca_cert' => 'ca.crt', 'server_cert' => 'server.crt', 'dh_params' => 'dh.pem' }.each do |key, file|
        next unless pki[key]
        line = pki[key].lines.map(&:strip).reject { |l| l.empty? || l.start_with?('-----') }.first
        next unless line
        test_command_succeeds("#{file} holds the supplied #{key}", "grep -qF '#{line}' #{dir}/#{file}", tier: 1)
      end
      if pki['server_key']
        test_command_succeeds('server.key is a private key', "grep -q 'PRIVATE KEY' #{dir}/server.key", tier: 1)
      end
      # server.conf carries the configured port, address, VPN subnet and pushed routes
      test_local_command('server.conf port', "cat #{dir}/server.conf", "port #{udp_port}") if udp_port
      test_local_command('server.conf local address', "cat #{dir}/server.conf", "local #{pki['server_ip']}") if pki['server_ip']
      if pki['vpn_subnet'] && pki['vpn_subnet_mask']
        test_local_command('server.conf VPN subnet', "cat #{dir}/server.conf",
                           "server #{pki['vpn_subnet']} #{pki['vpn_subnet_mask']}")
      end
      Array(pki['push_routes']).each do |route|
        test_local_command("server.conf pushes route #{route}", "cat #{dir}/server.conf", "push \"route #{route}\"")
      end
    end

    tier(2) do
      test_command_succeeds('openvpn binary works', 'openvpn --version')
      test_command_succeeds('server cert chains to CA',
                            "openssl verify -CAfile #{dir}/ca.crt #{dir}/server.crt")
      # start_on_boot decides whether the unit is running and bound to UDP
      if start_on_boot == 'true'
        test_local_command('openvpn-server@server active?', 'systemctl is-active openvpn-server@server | grep -x active', 'active')
        if udp_port
          test_local_command("openvpn listening on UDP #{udp_port}?", 'ss -lunp | grep openvpn', ":#{udp_port}")
        end
      elsif start_on_boot
        test_local_command('openvpn-server@server not running', 'systemctl is-active openvpn-server@server', 'inactive')
        test_local_command('openvpn-server@server not enabled', 'systemctl is-enabled openvpn-server@server', 'disabled')
      end
    end
  end
end

OpenvpnServerTest.new.run
