require_relative '../../../../../lib/post_provision_test'
require 'shellwords'

# Checks that /etc/hosts maps each supplied hostname to its IP address.
# hostnames and IP_addresses are parallel lists: hostnames[i] maps to IP_addresses[i].
class HostsTest < PostProvisionTest
  def initialize
    self.module_name = 'hosts'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super
    hostnames = self.json_inputs['hostnames'] || []
    ips = self.json_inputs['IP_addresses'] || []

    tier(1) do
      test_local_command('/etc/hosts present', 'test -f /etc/hosts && echo ok', 'ok')
      hostnames.each_with_index do |hostname, i|
        ip = ips[i]
        if ip.nil? || ip.empty?
          skip_check("#{hostname} has an IP", 'no IP_addresses entry for this hostname', tier: 1, evidence: nil)
          next
        end
        # an /etc/hosts line starting with the IP that lists the hostname
        awk = "awk -v ip=#{Shellwords.escape(ip)} -v h=#{Shellwords.escape(hostname)} " \
              "'$1==ip { for (i = 2; i <= NF; i++) if ($i == h) f = 1 } END { print (f ? \"found\" : \"missing\") }' /etc/hosts"
        test_local_command("#{hostname} -> #{ip} in /etc/hosts", awk, 'found')
      end
    end

    tier(2) do
      # the resolver works for the always-present loopback entry
      test_local_command('localhost resolves', 'getent hosts localhost', 'localhost')
      hostnames.each_with_index do |hostname, i|
        ip = ips[i]
        next if ip.nil? || ip.empty?
        # resolves through the system resolver (nsswitch), not just by grep
        test_local_command("#{hostname} resolves to #{ip}", "getent ahosts #{Shellwords.escape(hostname)}", ip)
      end
    end
  end
end

HostsTest.new.run
