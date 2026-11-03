require_relative '../../../../../lib/post_provision_test'


class SUIDviTest < PostProvisionTest
  def initialize
    self.module_name = 'suid_root_vi'
    self.module_path = get_module_path(__FILE__)
    super
  end

  # The module declares no read_fact or default_input: the files and mode
  # (4777, owner root) are fixed in suid_root_vi.pp, so nothing is read from
  # json_inputs here.
  def test_module
    super

    # Tier 1: every path the module sets is setuid (4777) and owned by root.
    # /usr/bin/vi and /etc/alternatives/vi are typically symlinks to the real
    # binary; -L follows them to the file whose mode actually matters.
    tier(1) do
      ['/usr/bin/vi', '/etc/alternatives/vi', '/usr/bin/vim.tiny', '/usr/bin/vim.basic'].each do |path|
        test_local_command("#{path} is setuid 4777 owned by root",
                           "stat -L -c '%a %U' #{path}", '4777 root')
      end
    end

    # Tier 2: an unprivileged user runs vi (via the vi alternative, whichever
    # binary it resolves to) in silent ex mode and reads /etc/shadow, proving
    # the process really has euid 0. The control shows /etc/shadow is
    # otherwise unreadable to that user, so the read cannot pass by accident.
    # No escalation to a root shell is attempted.
    tier(2) do
      user = 'nobody'
      vi_cmd = "$(readlink -f /usr/bin/vi)"
      test_command_succeeds('vi runs as an unprivileged user', "#{vi_cmd} --version", user: user)
      test_local_command('control: unprivileged user cannot cat /etc/shadow',
                         'cat /etc/shadow 2>&1', 'Permission denied', user: user)
      test_local_command('setuid vi reads /etc/shadow as an unprivileged user',
                         "#{vi_cmd} -u NONE -es -c 'r /etc/shadow' -c '%print' -c 'q!' /dev/null",
                         'root:', user: user)
    end

    # No tier 3: keeping the existing scope of this change to tier 2.
  end

end

SUIDviTest.new.run