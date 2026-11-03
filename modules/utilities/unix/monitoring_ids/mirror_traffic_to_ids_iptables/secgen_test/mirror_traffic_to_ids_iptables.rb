require_relative '../../../../../lib/post_provision_test'

class MirrorTrafficToIdsIptablesTest < PostProvisionTest
  def initialize
    self.module_name = 'mirror_traffic_to_ids_iptables'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super
    ids_ip = json_inputs['ids_IP_address']&.first
    tier(1) do
      test_local_command('iptables-persistent installed?', 'dpkg -l iptables-persistent | grep -E "^ii"', 'iptables-persistent')
      test_command_succeeds('rules.v4 saved', 'test -s /etc/iptables/rules.v4')
      test_local_command('netfilter-persistent enabled at boot', 'systemctl is-enabled netfilter-persistent', 'enabled')
    end
    tier(2) do
      test_command_succeeds('netfilter-persistent service active', 'systemctl is-active netfilter-persistent')
      if ids_ip
        # ids_IP_address: iptables -L prints TEE targets as 'gw:<ip>' (libxt_TEE); the TEE rule actually mirrors to the configured IDS host, not just any gateway
        test_local_command('TEE rule in mangle PREROUTING targets ids_IP_address',
                            "iptables -t mangle -L PREROUTING -n | grep TEE", "gw:#{ids_ip}")
        test_local_command('TEE rule in mangle FORWARD targets ids_IP_address',
                            "iptables -t mangle -L FORWARD -n | grep TEE", "gw:#{ids_ip}")
        test_local_command('TEE rule persisted to rules.v4',
                            'cat /etc/iptables/rules.v4', "--gateway #{ids_ip}")
      else
        test_local_command('TEE rule present in mangle PREROUTING', 'iptables -t mangle -L PREROUTING | grep TEE', 'TEE')
        test_local_command('TEE rule present in mangle FORWARD', 'iptables -t mangle -L FORWARD | grep TEE', 'TEE')
      end

      # Cross-VM checks when the scenario includes an ids_monitor system.
      # All IDS labs (4_ids.xml, 5_ids_rules.xml, 6_exfiltration_detection.xml,
      # hacker_vs_hackerbot_2.xml) use 'ids_monitor' as the system_name for the
      # Snort VM. These checks only run in full-scenario builds; single-VM
      # test-module builds skip them silently.
      if system_present?('ids_monitor')
        ids_monitor_ip = other_system_ip('ids_monitor')
        if ids_ip && ids_monitor_ip
          if ids_ip == ids_monitor_ip
            pass_check('ids_IP_address matches ids_monitor actual IP',
                       "TEE target #{ids_ip} matches ids_monitor's guest-agent IP", tier: 2)
          else
            fail_check('ids_IP_address matches ids_monitor actual IP',
                       "TEE target #{ids_ip} != ids_monitor IP #{ids_monitor_ip} — traffic not mirrored to IDS", tier: 2)
          end
        end

        # Snort must be installed on ids_monitor so mirrored packets can be inspected.
        snort_result = run_on_system('ids_monitor', 'dpkg -l snort-common | grep -E "^ii"')
        if snort_result[:stdout].include?('snort-common') && snort_result[:exit_status] == 0
          pass_check('snort-common installed on ids_monitor',
                     'Snort is installed on ids_monitor; mirrored traffic can be inspected', tier: 2)
        else
          fail_check('snort-common installed on ids_monitor',
                     'snort-common not found on ids_monitor — IDS cannot detect mirrored traffic', tier: 2)
        end
      end
    end
  end
end

MirrorTrafficToIdsIptablesTest.new.run
