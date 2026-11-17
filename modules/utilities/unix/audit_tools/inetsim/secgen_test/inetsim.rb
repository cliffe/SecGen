require_relative '../../../../../lib/post_provision_test'

class InetsimTest < PostProvisionTest
  # Sends one A query for a made-up name to the local resolver and prints the address in the answer.
  DNS_PROBE = <<~'PY'.freeze
    import socket
    name = b''.join(bytes([len(p)]) + p.encode() for p in 'secgen-probe.example'.split('.'))
    query = b'\x12\x34\x01\x00\x00\x01\x00\x00\x00\x00\x00\x00' + name + b'\x00\x00\x01\x00\x01'
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    s.settimeout(5)
    s.sendto(query, ('127.0.0.1', 53))
    print('answer=' + socket.inet_ntoa(s.recv(512)[-4:]))
  PY

  def initialize
    self.module_name = 'inetsim'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super
    dns_ip = self.json_inputs['dns_default_ip']&.first

    tier(1) do
      test_local_command('inetsim package installed?', "dpkg -l inetsim | grep '^ii'", 'inetsim')
      test_local_command('services bound to all interfaces', "grep '^service_bind_address' /etc/inetsim/inetsim.conf", 'service_bind_address 0.0.0.0')
      test_local_command('DNS answers set to dns_default_ip', "grep '^dns_default_ip' /etc/inetsim/inetsim.conf", "dns_default_ip #{dns_ip}") if dns_ip
    end

    add_evidence('inetsim log', 'tail -n 60 /var/log/inetsim/main.log 2>&1')
    add_evidence('listening sockets', 'ss -lntup 2>&1')

    tier(2) do
      test_http('/', match: 'INetSim', port: 80, label: 'fake HTTP server answers with its default page')
      if dns_ip
        test_local_command('fake DNS answers any name with dns_default_ip', "python3 -c #{Shellwords.escape(DNS_PROBE)}", "answer=#{dns_ip}")
      end
    end
  end
end

InetsimTest.new.run
