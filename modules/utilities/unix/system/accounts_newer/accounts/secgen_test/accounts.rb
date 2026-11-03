require_relative '../../../../../lib/post_provision_test'

# Tests that the accounts module (newer) created at least one user account.
# Specific usernames are scenario-controlled; we verify the mechanism works.
class AccountsTest < PostProvisionTest
  def initialize
    self.module_name = 'accounts'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super
    tier(1) do
      test_local_command('a user account was created', %q(awk -F: '$3>=1000 && $3<65534 {print $1}' /etc/passwd | grep -q . && echo ok), 'ok')
      test_local_command('/etc/passwd readable', 'test -r /etc/passwd && echo ok', 'ok')
      test_local_command('useradd present', 'command -v useradd', 'useradd')
      test_local_command('chpasswd present', 'command -v chpasswd', 'chpasswd')
    end
    tier(2) do
      result = run_command(%q(awk -F: '$3>=1000 && $3<65534 {print $1}' /etc/passwd))
      first_user = result[:stdout].strip.split("\n").first
      if first_user
        test_local_command("user #{first_user} resolvable via getent",
                           "getent passwd #{first_user}",
                           first_user)
        test_local_command("user #{first_user} has a home directory",
                           "h=$(getent passwd #{first_user} | cut -d: -f6); test -d \"$h\" && echo ok", 'ok')
        test_local_command("user #{first_user} password status",
                           "passwd -S #{first_user}", first_user)
        test_local_command("user #{first_user} id resolves", "id #{first_user}", 'uid=')
        test_command_succeeds("home dir exists for #{first_user}",
                              "test -d /home/#{first_user}")
      else
        skip_check('user account functional check', 'no UID>=1000 user found to verify', tier: 2, evidence: nil)
      end
    end
  end
end

AccountsTest.new.run
