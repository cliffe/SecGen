require_relative '../../../../../lib/post_provision_test'

class PasswordlessUserAccountTest < PostProvisionTest
  def initialize
    self.module_name = 'passwordless_user_account'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super
    usernames = (self.json_inputs['accounts'] || []).map { |j|
      begin; JSON.parse(j)['username']; rescue; nil; end
    }.compact

    tier(1) do
      if usernames.any?
        usernames.each { |u| test_local_command("user #{u} exists", "id #{u}", u) }
      else
        test_local_command('non-system user created', 'awk -F: \'$3 >= 1000 && $3 < 65534 {print $1}\' /etc/passwd', '.+')
      end
    end
    tier(2) do
      # Each user's shadow entry must have an empty password field
      if usernames.any?
        usernames.each { |u| test_local_command("#{u} has no password", "grep '^#{u}::' /etc/shadow", '::') }
      else
        test_local_command('passwordless entry in shadow', 'awk -F: \'$3 >= 1000 && $3 < 65534 {print $1}\' /etc/passwd | xargs -I{} grep "^{}::" /etc/shadow', '::')
      end
    end
    # TODO tier 3 (exploit): deferred — wire up test_msf_exploit when attacker VM is available
  end
end

PasswordlessUserAccountTest.new.run
