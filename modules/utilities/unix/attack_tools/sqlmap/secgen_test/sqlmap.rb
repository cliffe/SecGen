require_relative '../../../../../lib/post_provision_test'

class SqlmapTest < PostProvisionTest
  def initialize
    self.module_name = 'sqlmap'
    self.module_path = get_module_path(__FILE__)
    super
  end

  # No metadata inputs: the install directory and link directory are the Puppet class defaults.
  def test_module
    super
    tier(1) do
      test_local_command('git installed', 'dpkg -l git | grep -E "^ii"', 'git')
      test_local_command('sqlmap cloned', 'test -f /usr/share/sqlmap/sqlmap.py && echo /usr/share/sqlmap/sqlmap.py', '/usr/share/sqlmap/sqlmap.py')
      test_local_command('sqlmap checkout is a git clone', 'test -d /usr/share/sqlmap/.git && echo ok', 'ok')
      test_local_command('sqlmap symlinked', 'test -L /usr/local/bin/sqlmap && echo /usr/local/bin/sqlmap', '/usr/local/bin/sqlmap')
      test_local_command('symlink points at the clone', 'readlink /usr/local/bin/sqlmap', '/usr/share/sqlmap/sqlmap.py')
    end
    tier(2) do
      test_command_succeeds('sqlmap runs', 'sqlmap --version')
      # the clone is root-owned: an unprivileged user must be able to run it too
      test_command_succeeds('sqlmap runs as an unprivileged user', 'sqlmap --version', user: 'nobody')
      test_local_command('sqlmap prints its help', 'sqlmap -h 2>&1', 'Usage', user: 'nobody')
    end
  end
end

SqlmapTest.new.run
