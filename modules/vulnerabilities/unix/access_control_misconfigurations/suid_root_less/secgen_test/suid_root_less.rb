require_relative '../../../../../lib/post_provision_test'


class SUIDLessTest < PostProvisionTest
  def initialize
    self.module_name = 'suid_root_less'
    self.module_path = get_module_path(__FILE__)
    super
  end

  # The module declares no read_fact or default_input: the files and mode
  # (4777, owner root) are fixed in suid_root_less.pp, so nothing is read from
  # json_inputs here.
  def test_module
    super

    # Tier 1: both paths the module sets are setuid (4777) and owned by root.
    tier(1) do
      ['/bin/less', '/usr/bin/less'].each do |path|
        test_local_command("#{path} is setuid 4777 owned by root",
                           "stat -L -c '%a %U' #{path}", '4777 root')
      end
    end

    # Tier 2: an unprivileged user runs less and it acts as root. The control
    # shows /etc/shadow really is unreadable to that user, so the less read
    # cannot pass by accident. No escalation to a root shell is attempted.
    tier(2) do
      user = 'nobody'
      test_command_succeeds('less runs as an unprivileged user', '/bin/less --version', user: user)
      test_local_command('control: unprivileged user cannot cat /etc/shadow',
                         'cat /etc/shadow 2>&1', 'Permission denied', user: user)
      test_local_command('setuid less reads /etc/shadow as an unprivileged user',
                         '/bin/less /etc/shadow | head -n 1', 'root:', user: user)
    end

    # No tier 3: there is no Metasploit module for this misconfiguration; the
    # shell escape from less is left to a supervised session.
  end

end

SUIDLessTest.new.run
