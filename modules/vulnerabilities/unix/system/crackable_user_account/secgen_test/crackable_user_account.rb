require_relative '../../../../../lib/post_provision_test'
require 'json'

class CrackableUserAccountTest < PostProvisionTest
  def initialize
    self.module_name = 'crackable_user_account'
    self.module_path = get_module_path(__FILE__)
    super
  end

  # The crackable account's username, from whatever input shape the scenario
  # used: an `accounts`/`account` JSON object, or a bare `username`.
  def crackable_username
    %w[accounts account].each do |key|
      raw = self.json_inputs[key]&.first
      next if raw.to_s.empty?
      begin
        return JSON.parse(raw)['username']
      rescue StandardError
        next
      end
    end
    self.json_inputs['username']&.first
  end

  def test_module
    super
    username = crackable_username

    return skip_check('crackable user account', 'no account/username input to identify the created user') unless username

    tier(1) do
      # The unprivileged account the module creates must exist. test_local_command
      # matches its string literally (not as a regex), so assert the actual
      # username in id's output rather than a regex like '.+'.
      test_local_command("user #{username} exists", "id -un #{Shellwords.escape(username)}", username)
    end
    tier(2) do
      # That user has a crackable (hashed, non-locked) SHA-512 password in /etc/shadow.
      test_local_command('crackable SHA-512 hash in shadow',
                         "getent shadow #{Shellwords.escape(username)}", '$6$')
    end
    # TODO tier 3 (exploit): deferred — wire up test_msf_exploit when attacker VM is available
  end
end

CrackableUserAccountTest.new.run
