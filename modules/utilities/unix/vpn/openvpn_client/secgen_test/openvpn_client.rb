require_relative '../../../../../lib/post_provision_test'
require 'json'
require 'shellwords'

class OpenvpnClientTest < PostProvisionTest
  CONF = '/etc/openvpn/client/client.ovpn'
  UNIT = 'openvpn-client@client'

  def initialize
    self.module_name = 'openvpn_client'
    self.module_path = get_module_path(__FILE__)
    super
  end

  # Skipped input: none. openvpn_pki, client_index and start_on_boot are all
  # visible on the box (client.ovpn contents and the service state).
  def test_module
    super

    pki = begin
      JSON.parse(self.json_inputs['openvpn_pki']&.first.to_s)
    rescue JSON::ParserError
      nil
    end
    index = (self.json_inputs['client_index']&.first || 0).to_i
    client = pki && pki['clients'] && pki['clients'][index]
    start_on_boot = self.json_inputs['start_on_boot']&.first

    tier(1) do
      test_local_command('openvpn installed', 'which openvpn', '/usr/sbin/openvpn')
      test_local_command('client config directory exists', 'test -d /etc/openvpn/client && echo ok', 'ok')
      test_local_command('client config directory is root-only (0750)', 'stat -c "%a %U:%G" /etc/openvpn/client', '750 root:root')
      test_local_command('client.ovpn present', "test -f #{CONF} && echo ok", 'ok')
      test_local_command('client.ovpn is 0640 root:root', "stat -c '%a %U:%G' #{CONF}", '640 root:root')
      test_local_command('client.ovpn has inline ca, cert and key blocks',
        "grep -c -E '^</?(ca|cert|key)>$' #{CONF}", '6')
      test_local_command('client.ovpn defaults', "grep -E '^(client|dev tun|proto udp)$' #{CONF}", 'dev tun')

      if pki
        # server address and port from the PKI bundle end up on the remote line
        test_local_command('client.ovpn remote line',
          "grep '^remote ' #{CONF}", "remote #{pki['server_ip']} #{pki['port']}")
        # a distinctive body line of each PEM from the bundle is in the config
        { 'CA certificate' => pki['ca_cert'],
          'client certificate' => client && client['client_cert'],
          'client key' => client && client['client_key'] }.each do |label, pem|
          line = pem.to_s.lines.map(&:strip).reject { |l| l.empty? || l.start_with?('-----') }.first
          next unless line
          test_local_command("client.ovpn contains the #{label} (client_index #{index})",
            "grep -qF -- #{Shellwords.escape(line)} #{CONF} && echo ok", 'ok')
        end
      else
        fail_check('openvpn_pki input present and valid JSON', 'json_inputs has no parseable openvpn_pki', tier: 1)
      end
    end

    tier(2) do
      test_command_succeeds('openvpn --version runs', "openvpn --version | grep -q '^OpenVPN '")
      test_local_command('openvpn reports its version', 'openvpn --version 2>&1 || true', 'OpenVPN')
      # openvpn parses the whole client config (inline blocks included) before listing ciphers
      test_local_command('openvpn accepts client.ovpn',
        "openvpn --config #{CONF} --show-ciphers >/dev/null 2>&1 && echo ok", 'ok')
      # Config file must be non-empty (contains certs/keys injected from openvpn_pki generator)
      test_local_command('client.ovpn non-empty', "test -s #{CONF} && echo ok", 'ok')

      # start_on_boot: true means enabled at boot, false means stopped and disabled.
      # The running state is only asserted for false, as a started tunnel needs the VPN server up.
      case start_on_boot
      when 'true'
        test_local_command('openvpn client service enabled', "systemctl is-enabled #{UNIT} 2>&1", 'enabled')
      when 'false'
        test_local_command('openvpn client service disabled', "systemctl is-enabled #{UNIT} 2>&1", 'disabled')
        test_local_command('openvpn client service not running', "systemctl is-active #{UNIT} 2>&1", 'inactive')
      end
    end
  end
end

OpenvpnClientTest.new.run
