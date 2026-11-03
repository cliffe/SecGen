require_relative '../../../../../lib/post_provision_test'
require 'shellwords'
require 'json'

# Verifies that leak_to_file wrote the supplied base64 content to the leaked file.
# The Puppet uses only the first value of each input. With an account input the
# file goes in /home/<username>/ owned by that user; otherwise in
# storage_directory, owned by root.
class LeakToFileTest < PostProvisionTest
  def initialize
    self.module_name = 'leak_to_file'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super
    storage_dir  = self.json_inputs['storage_directory']&.first
    leaked_fname = self.json_inputs['leaked_filename']&.first.to_s
    b64          = self.json_inputs['base64_file']&.first.to_s.gsub(/\s/, '')

    username = nil
    if (raw = self.json_inputs['account']&.first) && !raw.to_s.empty?
      account = raw.is_a?(String) ? (JSON.parse(raw) rescue nil) : raw
      username = account['username'] if account.is_a?(Hash)
    end
    dir   = username ? "/home/#{username}" : storage_dir
    owner = username || 'root'

    if !leaked_fname.empty? && dir
      path = Shellwords.escape("#{dir}/#{leaked_fname}")
      tier(1) do
        test_local_command("#{leaked_fname} present in #{dir}", "test -f #{path} && echo ok", 'ok')
        # Puppet default owner, group (both the target account or root) and mode 0660
        test_local_command("#{leaked_fname} owner and mode", "stat -c '%U:%G %a' #{path}", "#{owner}:#{owner} 660")
        # content is the decoded base64_file
        unless b64.empty?
          test_local_command("#{leaked_fname} content matches base64_file", "base64 -w0 #{path}", b64)
        end
      end
      tier(2) do
        # the owning user can read the leaked file (as an attacker with that account would)
        test_command_succeeds("#{leaked_fname} readable by #{owner}", "test -r #{path}", user: owner)
        unless b64.empty?
          test_command_succeeds("#{leaked_fname} non-empty", "test -s #{path}", user: owner)
        end
      end
    else
      tier(1) do
        # No filename supplied: the module leaks nothing, so there is nothing to find.
        pass_check('nothing to leak', 'no filename input, so the module writes no file', tier: 1)
      end
    end
  end
end

LeakToFileTest.new.run
