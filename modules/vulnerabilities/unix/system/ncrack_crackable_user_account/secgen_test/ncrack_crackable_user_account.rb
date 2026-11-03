require_relative '../../../../../lib/post_provision_test'

class NcrackCrackableUserAccountTest < PostProvisionTest
  def initialize
    self.module_name = 'ncrack_crackable_user_account'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super
    username = self.json_inputs['username']&.first ||
               begin; JSON.parse(self.json_inputs['account']&.first || '')['username']; rescue; nil; end

    tier(1) do
      if username
        test_local_command("user #{username} exists", "id #{username}", username)
      else
        test_local_command('non-system user created', 'awk -F: \'$3 >= 1000 && $3 < 65534 {print $1}\' /etc/passwd', '.+')
      end
    end
    tier(2) do
      # User has a hashed (non-locked) password — ncrack will brute-force it over SSH
      test_local_command('ncrack-crackable hash in shadow', 'awk -F: \'$3 >= 1000 && $3 < 65534 {print $1}\' /etc/passwd | xargs -I{} grep "^{}" /etc/shadow | grep -v "^[^:]*:!"', '$6$')
    end
    # TODO tier 3 (exploit): deferred — wire up ncrack over SSH from attacker VM
  end
end

NcrackCrackableUserAccountTest.new.run
