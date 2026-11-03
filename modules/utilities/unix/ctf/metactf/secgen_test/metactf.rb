require_relative '../../../../../lib/post_provision_test'
require 'json'
require 'shellwords'

class MetactfTest < PostProvisionTest
  def initialize
    self.module_name = 'metactf'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super
    # include_scaffolding, challenge 'port' and 'copy_directory': port/copy_directory are passed to
    # install_setgid_binary, which does not use them, so there is nothing on the box to check.
    tier(1) do
      %w[zsh build-essential gcc-multilib bc].each do |pkg|
        test_local_command("#{pkg} package installed", "dpkg-query -W -f='${Status}' #{pkg}", 'install ok installed')
      end
      test_local_command('metactf repository installed', 'ls /opt/metactf', 'install.sh')
      %w[src_angr src_csp src_malware src_sse].each do |category|
        test_local_command("#{category} sources present", 'ls /opt/metactf', category)
        test_local_command("#{category} binaries built", "find /opt/metactf/#{category} -type d -name secgen -print -quit", 'secgen')
      end
    end

    account = JSON.parse(Array(json_inputs['account']).first || '{}')
    user = account['username']
    challenges = Array(json_inputs['challenge_list']).map { |c| JSON.parse(c) }
    skip!('no account or challenge_list input') if user.nil? || challenges.empty?

    challenges.each do |challenge|
      name = challenge['challenge_name']
      dir = "/home/#{user}/challenges/#{name}"
      bin = Shellwords.escape("#{dir}/#{name}")
      flag_file = Shellwords.escape("#{dir}/flag")

      # built binary the challenge was copied from (src_angr uses a different obj layout)
      category = challenge['challenge_path'].to_s.split('/').first
      built = category == 'src_angr' ? "/opt/metactf/#{category}/obj/secgen/angr/#{name}" : "/opt/metactf/#{challenge['challenge_path']}/obj/secgen/#{name}"
      tier(1) { test_local_command("#{name}: built binary", "test -x #{Shellwords.escape(built)} && echo built", 'built') }

      # challenge directory belongs to the account
      tier(1) { test_local_command("#{name}: directory owned by #{user}", "stat -c '%U' #{Shellwords.escape(dir)}", user) }

      # include_scaffolding: src_angr challenges get scaffoldNN.py when it is true
      if category == 'src_angr'
        scaffold = "#{dir}/scaffold#{name.split('_').first}.py"
        scaffolding_on = self.json_inputs['include_scaffolding']&.first.to_s.downcase == 'true'
        tier(1) do
          if scaffolding_on
            test_local_command("#{name}: scaffold file present", "test -s #{Shellwords.escape(scaffold)} && echo scaffold", 'scaffold')
          else
            test_command_succeeds("#{name}: no scaffold file", "! test -e #{Shellwords.escape(scaffold)}", tier: 1)
          end
        end
      end

      # include_c: the C source is shipped beside the binary
      tier(1) do
        if challenge['include_c'].to_s.downcase == 'true'
          test_local_command("#{name}: program.c present", "test -s #{Shellwords.escape(dir)}/program.c && echo source", 'source')
        end
      end

      # placed by secgen_functions::install_setgid_binary: setgid to the challenge's group, flag readable only by it
      tier(1) do
        test_local_command("#{name}: setgid binary", "stat -c '%a %G' #{bin}", "2775 #{challenge['group']}")
        test_local_command("#{name}: flag file", "stat -c '%a %U %G' #{flag_file}", "760 root #{challenge['group']}")
        test_local_command("#{name}: flag value", "cat #{flag_file}", challenge['flag'])
      end

      tier(2) do
        # the challenge binary runs as the student and prints something (a prompt) rather than failing to execute
        test_command_succeeds("#{name}: binary runs as #{user}",
                              "cd #{Shellwords.escape(dir)} && test -x ./#{Shellwords.escape(name)} && out=$(printf '\\n' | timeout 10 ./#{Shellwords.escape(name)} 2>&1); test -n \"$out\"", user: user)
        test_command_succeeds("#{name}: student cannot read the flag directly", "! cat #{flag_file}", user: user)
        # A challenge built with empty randomised values (e.g. build.zsh without bc) typically accepts an empty or
        # arbitrary password; a correctly built one releases the flag only for its password.
        %w[empty wrong].each do |kind|
          input = kind == 'empty' ? '\n' : 'secgen-wrong-password\n'
          out = run_as_user(user, "cd #{Shellwords.escape(dir)} && printf '#{input}' | timeout 10 ./#{Shellwords.escape(name)} 2>&1")
          if out[:stdout].include?(challenge['flag']) || out[:stderr].include?(challenge['flag'])
            fail_check("#{name}: #{kind} password rejected", 'the flag was released (challenge built with empty values?)')
          elsif [126, 127].include?(out[:exit_status])
            fail_check("#{name}: #{kind} password rejected", "the binary did not run (exit #{out[:exit_status]})")
          else
            pass_check("#{name}: #{kind} password rejected")
          end
        end
      end
    end
  end
end

MetactfTest.new.run
