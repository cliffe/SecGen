require_relative '../../../../../lib/post_provision_test'

# Verifies that the groups module created each group named in the `groups` input.
class GroupsTest < PostProvisionTest
  def initialize
    self.module_name = 'groups'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super
    groups = (self.json_inputs['groups'] || []).reject { |g| g.to_s.strip.empty? }
    tier(1) do
      test_command_succeeds('/etc/group readable', 'test -r /etc/group')
      test_local_command('groups exist in /etc/group', 'test -s /etc/group && echo ok', 'ok')
      groups.each do |g|
        test_local_command("group #{g} in /etc/group", "grep -E '^#{g}:' /etc/group", "#{g}:")
      end
    end
    tier(2) do
      test_command_succeeds('getent group works', 'getent group root')
      groups.each do |g|
        test_local_command("group #{g} resolves via getent", "getent group #{g}", "#{g}:")
      end
    end
  end
end

GroupsTest.new.run
