require_relative '../../../../../lib/post_provision_test'
require 'shellwords'
require 'json'

# Each `accounts` input is a JSON account (username, password, groups, super_user,
# strings_to_leak, leaked_filenames, data_to_leak). The module creates the user
# with a bash shell and home directory, SHA-512 password hash (salt "mysalt"),
# groups, an optional sudoers line, and leaks files into /home/<username>/.
class ParameterisedAccountsTest < PostProvisionTest
  def initialize
    self.module_name = 'parameterised_accounts'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super
    accounts = (self.json_inputs['accounts'] || []).map { |a| a.is_a?(String) ? (JSON.parse(a) rescue nil) : a }.compact
    accounts.each { |account| test_account(account) }
  end

  def test_account(account)
    user = account['username'].to_s
    return if user.empty?
    home = "/home/#{user}"
    u = Shellwords.escape(user)

    tier(1) do
      test_local_command("#{user} account exists", "getent passwd #{u}", "#{user}:")
      test_local_command("#{user} shell and home", "getent passwd #{u}", ":#{home}:/bin/bash")
      test_local_command("#{user} home directory exists", "test -d #{Shellwords.escape(home)} && echo ok", 'ok')

      Array(account['groups']).map(&:to_s).reject(&:empty?).each do |group|
        test_local_command("#{user} in group #{group}", "id -nG #{u} | tr ' ' '\\n' | grep -x #{Shellwords.escape(group)}", group)
      end

      check_password(user, account['password'].to_s)

      if account['super_user'].to_s == 'true'
        test_local_command("#{user} has a sudoers entry", 'cat /etc/sudoers', "#{user} ALL=(ALL) ALL")
      end

      # strings_to_leak[i] is written to leaked_filenames[i] (extra strings go in the first file)
      names = Array(account['leaked_filenames']).map(&:to_s)
      Array(account['strings_to_leak']).each_with_index do |strings, i|
        file = names[i] || names[0]
        next if file.nil? || file.empty?
        path = Shellwords.escape("#{home}/#{file}")
        test_local_command("#{user}: #{file} owner and mode", "stat -c '%U:%G %a' #{path}", "#{user}:#{user} 600")
        Array(strings).map(&:to_s).flat_map { |s| s.split("\n") }.reject { |s| s.strip.empty? }.each do |s|
          test_command_succeeds("#{user}: #{file} contains leaked string", "grep -qF -- #{Shellwords.escape(s)} #{path}", tier: 1)
        end
      end

      # data_to_leak: JSON {"secgen_leaked_data": {data (base64), filename, ext, subdirectory}}
      Array(account['data_to_leak']).each do |raw|
        d = (raw.is_a?(String) ? (JSON.parse(raw) rescue nil) : raw)
        d = d['secgen_leaked_data'] if d.is_a?(Hash)
        next unless d.is_a?(Hash) && d['filename']
        full = d['ext'].to_s.empty? ? d['filename'] : "#{d['filename']}.#{d['ext']}"
        sub = d['subdirectory'].to_s.empty? ? '' : "#{d['subdirectory']}/"
        path = Shellwords.escape("#{home}/#{sub}#{full}")
        test_local_command("#{user}: leaked data file #{sub}#{full} present", "test -f #{path} && echo ok", 'ok')
        data = d['data'].to_s.gsub(/\s/, '')
        test_local_command("#{user}: #{full} content", "base64 -w0 #{path}", data) unless data.empty?
      end
    end

    tier(2) do
      # the account is usable: a shell as that user works and can enter its home.
      # (runuser -u keeps the caller's cwd, so plain `pwd` would print / - resolve ~user via passwd instead)
      test_local_command("#{user} can run commands", 'id -un', user, user: user)
      test_local_command("#{user} can enter its home (~#{user})", "cd ~#{u} && pwd", home, user: user)
      if account['super_user'].to_s == 'true'
        test_local_command("#{user} is allowed to sudo", "sudo -l -U #{u}", 'ALL')
      end
      names = Array(account['leaked_filenames']).map(&:to_s).reject(&:empty?)
      names.each do |file|
        test_command_succeeds("#{user} can read #{file}", "test -r #{Shellwords.escape("#{home}/#{file}")}", user: user)
      end
    end
  end

  # Compare the shadow entry with the SHA-512 hash the module generates (salt "mysalt");
  # an empty password is removed with passwd -d, leaving an empty field.
  def check_password(user, password)
    entry = run_command("getent shadow #{Shellwords.escape(user)}")
    if entry[:exit_status] != 0
      return fail_check("#{user} password", "#{user} has no shadow entry", tier: 1)
    end
    shadow = entry[:stdout].split(':')[1].to_s.strip
    if password.empty?
      shadow.empty? ? pass_check("#{user} has no password", "#{user} password field is empty", tier: 1) :
                      fail_check("#{user} has no password", "#{user} has a password hash but none was requested", tier: 1)
      return
    end
    expected = begin
      password.crypt('$6$mysalt$')
    rescue StandardError, NotImplementedError
      nil
    end
    if expected.nil? || !expected.start_with?('$6$mysalt$')
      skip_check("#{user} password hash", 'SHA-512 crypt unavailable in the test runner', tier: 1, evidence: nil)
    elsif shadow == expected
      pass_check("#{user} password hash matches", "#{user} password hash matches the supplied password", tier: 1)
    else
      fail_check("#{user} password hash matches", "#{user} password hash differs from the supplied password", tier: 1)
    end
  end
end

ParameterisedAccountsTest.new.run
