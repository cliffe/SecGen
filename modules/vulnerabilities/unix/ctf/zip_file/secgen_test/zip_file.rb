require_relative '../../../../../lib/post_provision_test'

class ZipFileTest < PostProvisionTest
  def initialize
    self.module_name = 'zip_file'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super
    leaked_fname = self.json_inputs['leaked_filename']&.first.to_s
    storage_dir  = self.json_inputs['storage_directory']&.first
    mode         = self.json_inputs['mode']&.first.to_s.sub(/\A0+(?=\d)/, '')

    # init.pp: an account puts the zip in that user's home, otherwise storage_directory
    username = nil
    if (raw = self.json_inputs['account']&.first) && !raw.to_s.empty?
      account = raw.is_a?(String) ? (JSON.parse(raw) rescue nil) : raw
      username = account['username'] if account.is_a?(Hash)
    end
    dir   = username ? "/home/#{username}" : storage_dir
    owner = username || 'root'
    return skip_check('zip leaked', 'no leaked_filename or storage directory input') if leaked_fname.empty? || dir.nil?

    path = Shellwords.escape("#{dir}/#{leaked_fname}")
    tier(1) do
      test_local_command("#{leaked_fname} present in #{dir}", "test -f #{path} && echo ok", 'ok')
      test_local_command("#{leaked_fname} owner and mode", "stat -c '%U:%G %a' #{path}", "#{owner}:#{owner} #{mode}") unless mode.empty?
    end
    tier(2) do
      # ZIP files start with PK magic bytes (50 4b 03 04)
      test_local_command("#{leaked_fname} is a zip (PK magic bytes)", "head -c4 #{path} | od -An -tx1", '50 4b 03 04')
    end
    # TODO tier 3 (exploit): deferred — challenge is a CTF analysis task, no remote exploit
  end
end

ZipFileTest.new.run
