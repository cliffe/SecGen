require_relative '../../../../../lib/post_provision_test'

class HiddenFileTest < PostProvisionTest
  def initialize
    self.module_name = 'hidden_file'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super
    tier(1) do
      # A challenge directory is created under an account home (or storage_directory).
      # The path is parameterised, so check that at least one challenge dir exists anywhere.
      test_local_command('challenge directory created', 'find /home /root -mindepth 2 -maxdepth 2 -type d | head -1', '/')
    end
    tier(2) do
      # A dotfile (hidden file) is dropped inside the challenge directory.
      test_local_command('hidden dotfile exists', 'find /home /root -mindepth 2 -name ".*" -type f | head -1', '/')
    end
    # TODO tier 3 (exploit): deferred — challenge is a CTF discovery task, no remote exploit
  end
end

HiddenFileTest.new.run
