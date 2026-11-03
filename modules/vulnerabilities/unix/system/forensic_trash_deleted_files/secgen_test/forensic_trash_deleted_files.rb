require_relative '../../../../../lib/post_provision_test'
require 'json'
require 'shellwords'

class ForensicTrashDeletedFilesTest < PostProvisionTest
  def initialize
    self.module_name = 'forensic_trash_deleted_files'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super

    # Inputs (all read through json_inputs, none hardcoded):
    #   account                 checked: owner and location of the Trash directory
    #   leaked_filenames        checked: file names under Trash/files and Trash/info
    #   strings_to_leak         checked: content of those files
    #   leaked_base64_filenames checked: file names for the decoded binary files
    #   binary_base64_to_leak   checked: decoded content re-encodes to the input
    account_json = (self.json_inputs['account'] || []).first
    account = account_json.to_s.empty? ? nil : JSON.parse(account_json)
    username = account && account['username']
    leaked_filenames = self.json_inputs['leaked_filenames'] || []
    strings_to_leak = self.json_inputs['strings_to_leak'] || []
    base64_filenames = self.json_inputs['leaked_base64_filenames'] || []
    base64_contents = self.json_inputs['binary_base64_to_leak'] || []

    trash = username ? "/home/#{username}/.local/share/Trash" : nil

    tier(1) do
      if trash
        test_local_command('Trash files dir exists for the account', "test -d #{trash.shellescape}/files && echo trash_files_ok", 'trash_files_ok')
        test_local_command('Trash info dir exists for the account', "test -d #{trash.shellescape}/info && echo trash_info_ok", 'trash_info_ok')
      else
        fail_check('account input present', 'json_inputs has no account, so the Trash location is unknown')
      end
    end

    return unless trash

    tier(2) do
      leaked_filenames.each_with_index do |name, i|
        path = "#{trash}/files/#{name}"
        test_local_command("deleted file #{name} exists", "test -f #{path.shellescape} && echo file_ok", 'file_ok')
        test_local_command("trashinfo for #{name} present", "cat #{"#{trash}/info/#{name}.trashinfo".shellescape}", '[Trash Info]')
        test_local_command("deleted file #{name} owned by #{username}", "stat -c %U #{path.shellescape}", username)
        if (content = strings_to_leak[i])
          test_local_command("deleted file #{name} holds the leaked string", "cat #{path.shellescape}", content)
        end
      end

      base64_filenames.each_with_index do |name, i|
        path = "#{trash}/files/#{name}"
        test_local_command("binary deleted file #{name} exists", "test -f #{path.shellescape} && echo file_ok", 'file_ok')
        test_local_command("trashinfo for #{name} present", "cat #{"#{trash}/info/#{name}.trashinfo".shellescape}", '[Trash Info]')
        if (encoded = base64_contents[i])
          # the module decodes the input, so re-encoding the file must give the input back
          test_local_command("binary deleted file #{name} decodes to the input", "base64 -w0 #{path.shellescape}", encoded.strip)
        end
      end
    end
  end
end

ForensicTrashDeletedFilesTest.new.run
