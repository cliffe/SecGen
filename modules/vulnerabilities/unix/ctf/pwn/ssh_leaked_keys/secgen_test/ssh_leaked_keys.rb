require_relative '../../../../../lib/post_provision_test'

class SshLeakedKeysTest < PostProvisionTest
  def initialize
    self.module_name = 'ssh_leaked_keys'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super
    tier(1) do
      test_local_command('user account exists', 'ls -d /home/*/ 2>/dev/null | head -1', '/home/')
      # An SSH key pair is deposited into the user's .ssh directory.
      test_local_command('private key placed', 'find /home -name "id_rsa" | head -1', 'id_rsa')
    end
    tier(2) do
      test_local_command('public key placed', 'find /home -name "id_rsa.pub" | head -1', 'id_rsa.pub')
      test_local_command('authorized_keys configured', 'find /home -name "authorized_keys" | head -1', 'authorized_keys')
    end
    # TODO tier 3 (exploit): deferred — exploit by using the leaked private key over SSH
  end
end

SshLeakedKeysTest.new.run
