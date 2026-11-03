require_relative '../../../../../lib/post_provision_test'
require 'shellwords'

class AliasRootkitTest < PostProvisionTest
  def initialize
    self.module_name = 'alias_rootkit'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super
    hidden_strings = self.json_inputs['hidden_strings'] || []
    hidden_ports = self.json_inputs['hidden_ports'] || []

    tier(1) do
      # The rootkit installs bash aliases that hide strings from common commands
      test_local_command('aliases in /root/.bashrc', "grep -q 'alias ps=' /root/.bashrc && echo found", 'found')
      # one alias per hooked command, in root's and the skeleton (so later accounts) bashrc
      ['/root/.bashrc', '/etc/skel/.bashrc'].each do |rc|
        %w[ps ls lsof netstat cat].each do |cmd|
          test_local_command("#{cmd} alias in #{rc}", "grep -cF \"alias #{cmd}='f(){\" #{rc}", '1')
        end
        test_local_command("sudo wrapper in #{rc}", "grep -c 'sudo_w' #{rc}", '1')
        # each configured hidden string and port appears in the filters
        hidden_strings.each do |str|
          test_local_command("hidden string '#{str}' in #{rc} ps alias", "grep 'alias ps=' #{rc}", str)
        end
        hidden_ports.each do |prt|
          test_local_command("hidden port #{prt} in #{rc} netstat alias", "grep 'alias netstat=' #{rc}", prt)
        end
      end
      # the non-interactive early return is stripped from the skeleton so the aliases load
      test_local_command('skel bashrc has no non-interactive return', "grep -c '^      \\*) return;;' /etc/skel/.bashrc | grep -x 0", '0')
    end
    tier(2) do
      # Aliases survive a bash invocation (non-interactive -c; use bash directly so they expand)
      test_command_succeeds('aliases expand in bash', "bash -i -c 'type ps' 2>&1 | grep -q alias")
      # behaviour: a file containing a hidden string is missing from ls, an ordinary file is not
      hidden_strings.each do |str|
        s = Shellwords.escape(str)
        test_command_succeeds("ls hides '#{str}'",
                              "d=$(mktemp -d); touch \"$d/keepfile\" \"$d/x_\"#{s}\"_y\"; " \
                              "out=$(bash -i -c \"ls $d\" 2>&1); rm -rf \"$d\"; " \
                              "echo \"$out\" | grep -q keepfile && ! echo \"$out\" | grep -qF -- #{s}")
      end
      # cat hides lines containing a hidden string
      hidden_strings.each do |str|
        s = Shellwords.escape(str)
        test_command_succeeds("cat hides lines containing '#{str}'",
                              "f=$(mktemp); printf 'shown\\nline_%s_x\\n' #{s} > \"$f\"; " \
                              "out=$(bash -i -c \"cat $f\" 2>&1); rm -f \"$f\"; " \
                              "echo \"$out\" | grep -q shown && ! echo \"$out\" | grep -qF -- #{s}")
      end
      # (ports are exercised only via the netstat alias text: netstat may not be installed on the base)
    end
  end
end

AliasRootkitTest.new.run
