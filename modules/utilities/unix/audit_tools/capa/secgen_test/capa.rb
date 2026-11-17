require_relative '../../../../../lib/post_provision_test'

class CapaTest < PostProvisionTest
  def initialize
    self.module_name = 'capa'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super
    user = regular_user || 'nobody'

    tier(1) do
      test_local_command('capa binary installed', 'test -x /opt/capa/capa && readlink /usr/local/bin/capa', '/opt/capa/capa')
    end

    tier(2) do
      test_local_command('capa reports its version', 'capa --version 2>&1', 'v9.4.0', user: user)
      # A full analysis of a small system binary: the report header lists the sample's hashes.
      result = run_as_user(user, 'capa /usr/bin/true 2>&1', timeout: 300)
      name = "capa analyses an ELF binary as #{user}"
      if result[:exit_status].to_i.zero? && result[:stdout].to_s.include?('sha256')
        pass_check(name)
      else
        fail_check(name, "exit #{result[:exit_status]}: #{result[:stdout].to_s[-500..] || result[:stdout]} #{result[:stderr]}")
      end
    end
  end
end

CapaTest.new.run
