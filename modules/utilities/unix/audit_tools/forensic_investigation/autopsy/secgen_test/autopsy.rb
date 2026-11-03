require_relative '../../../../../lib/post_provision_test'

class AutopsyTest < PostProvisionTest
  def initialize
    self.module_name = 'autopsy'
    self.module_path = get_module_path(__FILE__)
    super
  end

  # No inputs: the module only installs the package.
  def test_module
    super
    tier(1) do
      test_local_command('autopsy installed?', 'dpkg -l autopsy | grep "^ii"', 'autopsy')
      # autopsy is a front end to The Sleuth Kit, which its package depends on
      test_local_command('sleuthkit command line tools present', 'command -v fls icat', '/fls')
    end
    tier(2) do
      test_local_command('autopsy binary present', 'test -x /usr/bin/autopsy && echo "ok"', 'ok')
      # the web UI needs an evidence locker, so run the script with its usage/help output instead (lower-cased to
      # match whichever wording it prints) and check the Sleuth Kit back end answers
      test_local_command('autopsy runs as an unprivileged user', 'command -v autopsy >/dev/null && timeout 30 autopsy -h </dev/null 2>&1 | tr A-Z a-z', 'autopsy', user: 'nobody')
      test_command_succeeds('sleuthkit fls runs as an unprivileged user', 'fls -V', user: 'nobody')
    end
  end
end

AutopsyTest.new.run
