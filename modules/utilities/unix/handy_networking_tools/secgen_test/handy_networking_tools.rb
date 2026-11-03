require_relative '../../../../../lib/post_provision_test'

class HandyNetworkingToolsTest < PostProvisionTest
  def initialize
    self.module_name = 'handy_networking_tools'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super
    disable_ntp = self.json_inputs['disable_ntp']&.first.to_s.downcase
    # wireshark and nmap come from their own required modules and are tested there.

    tier(1) do
      test_local_command('curl installed', 'which curl', 'curl')
      test_local_command('tcpdump installed', 'which tcpdump', 'tcpdump')
      test_local_command('openssl installed', 'which openssl', 'openssl')
      # every package the Puppet installs, and the binary it provides
      # dnsutils was renamed to bind9-dnsutils on Kali rolling; check either name
      test_local_command('dnsutils package installed', "dpkg -l dnsutils bind9-dnsutils 2>/dev/null | grep -E '^ii'", 'dnsutils')
      test_local_command('dig on PATH', 'PATH=$PATH:/sbin:/usr/sbin command -v dig', 'dig')
      { 'openvpn' => 'openvpn', 'traceroute' => 'traceroute', 'whois' => 'whois',
        'net-tools' => 'netstat', 'resolvconf' => 'resolvconf' }.each do |pkg, bin|
        test_local_command("#{pkg} package installed", "dpkg -l #{pkg} | grep -E '^ii'", pkg)
        test_local_command("#{bin} on PATH", "PATH=$PATH:/sbin:/usr/sbin command -v #{bin}", bin)
      end
      test_local_command('nslookup on PATH', 'command -v nslookup', 'nslookup')
      test_local_command('ifconfig on PATH', 'PATH=$PATH:/sbin command -v ifconfig', 'ifconfig')
    end
    tier(2) do
      test_command_succeeds('curl runs', 'curl --version')
      test_command_succeeds('openssl runs', 'openssl version')
      test_local_command('traceroute available', 'which traceroute', 'traceroute')
      test_local_command('tcpdump runs', 'tcpdump --version 2>&1', 'tcpdump version')
      test_local_command('dig runs', 'dig -v 2>&1', 'DiG')
      test_local_command('nslookup runs', 'command -v nslookup >/dev/null && nslookup -version 2>&1', 'nslookup')
      test_local_command('openvpn runs', 'openvpn --version', 'OpenVPN')
      test_local_command('traceroute runs', 'command -v traceroute >/dev/null && traceroute --version 2>&1', 'traceroute')
      test_local_command('whois runs', 'command -v whois >/dev/null && whois --version 2>&1', 'whois')
      test_local_command('netstat runs', 'netstat --version 2>&1', 'net-tools')
      test_local_command('ifconfig lists loopback', 'PATH=$PATH:/sbin ifconfig lo', 'lo')
      test_command_succeeds('resolvconf lists state', 'PATH=$PATH:/sbin resolvconf -l')
      test_local_command('openssl hashes a known string', 'echo secgen | openssl dgst -sha256', 'e1f96961e32c572796f8204a6eee93e8802e60921f2ce62dd30a7efe1582a14f')
      # disable_ntp: only acts when true (stops and disables systemd-timesyncd)
      if disable_ntp == 'true'
        test_local_command('systemd-timesyncd not active', 'systemctl is-active systemd-timesyncd', 'inactive')
        test_local_command('systemd-timesyncd disabled', 'systemctl is-enabled systemd-timesyncd', 'disabled')
      end
    end
  end
end

HandyNetworkingToolsTest.new.run
