require_relative '../../../../../lib/post_provision_test'

class SandboxingToolsTest < PostProvisionTest
  def initialize
    self.module_name = 'sandboxing_tools'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super
    user = regular_user || 'nobody'

    tier(1) do
      %w[bubblewrap firejail].each do |pkg|
        test_local_command("#{pkg} package installed?", "dpkg -l #{pkg} | grep '^ii'", pkg)
      end
    end

    add_evidence('user namespaces', 'sysctl kernel.unprivileged_userns_clone user.max_user_namespaces 2>&1')

    # Each sandbox drops the network: inside it the only interface is loopback.
    tier(2) do
      { 'bubblewrap' => 'bwrap --ro-bind / / --dev /dev --proc /proc --unshare-net /sbin/ip -o link',
        'firejail'   => 'firejail --quiet --noprofile --net=none /sbin/ip -o link' }.each do |tool, cmd|
        result = run_as_user(user, "#{cmd} 2>&1")
        ifaces = result[:stdout].to_s.lines.map { |l| l.split(':')[1].to_s.strip }.reject(&:empty?)
        name = "#{tool} runs a command as #{user} with no network"
        if result[:exit_status].to_i.zero? && ifaces == ['lo']
          pass_check(name)
        else
          fail_check(name, "exit #{result[:exit_status]}: #{result[:stdout]} #{result[:stderr]}".strip[0, 800])
        end
      end
    end
  end
end

SandboxingToolsTest.new.run
