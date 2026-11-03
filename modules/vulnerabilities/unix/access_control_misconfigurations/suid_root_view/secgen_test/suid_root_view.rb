require_relative '../../../../../lib/post_provision_test'


class SUIDviewTest < PostProvisionTest
  def initialize
    self.module_name = 'suid_root_view'
    self.module_path = get_module_path(__FILE__)
    super
  end

  # The module declares no read_fact or default_input: the files and mode it
  # changes (/usr/bin/view and /etc/alternatives/view, 4777, root) are fixed.
  # Unprivileged probe account: nobody (exists on every base).
  def test_module
    super
    real = '$(readlink -f /usr/bin/view)'

    tier(1) do
      test_local_command('view resolves to a vim binary', 'readlink -f /usr/bin/view', '/usr/bin/vim')
      test_local_command('real view binary is root-owned and setuid (4777)',
                         "stat -c '%U %a' #{real}", 'root 4777')
      test_local_command('/etc/alternatives/view points at the same setuid file',
                         "stat -L -c '%U %a' /etc/alternatives/view", 'root 4777')
    end

    tier(2) do
      test_command_succeeds('unprivileged user can run view', 'view --version', user: 'nobody')

      # Start view as nobody on a FIFO, so it blocks in open() with no way to
      # leave the editor, and read the process's uids from /proc. The real uid
      # is nobody's and the effective uid is 0: the setuid bit is honoured,
      # without using the editor to get a shell.
      probe = 'd=$(mktemp -d); mkfifo "$d/f"; view -es -u NONE "$d/f" >/dev/null 2>&1 & p=$!; sleep 2; ' \
              'awk \'/^Uid:/ {print "euid=" $3, ($2 != 0 ? "unprivileged" : "root")}\' /proc/$p/status; ' \
              'kill $p 2>/dev/null; wait $p 2>/dev/null; rm -rf "$d"'
      test_local_command('view run by nobody has effective uid 0', probe, 'euid=0 unprivileged', user: 'nobody')
    end
    # No tier 3: this issue asks for tier 2 only.
  end

end

SUIDviewTest.new.run
