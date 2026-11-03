require_relative '../../../../../lib/post_provision_test'

class SambaPublicWritableShareTest < PostProvisionTest
  def initialize
    self.module_name = 'samba_public_writable_share'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super
    # An organisation input renames the share and its comment (samba_share_name).
    share_name, share_comment = samba_share_name
    storage_directory = self.json_inputs['storage_directory']&.first
    guests_allowed = self.json_inputs['guests_allowed']&.first != 'false'
    read_only = self.json_inputs['read_only_share']&.first == 'true'
    writable_expected = guests_allowed && !read_only

    tier(1) do
      test_local_command('samba installed', 'dpkg -l samba | grep -E "^ii"', 'samba')
      test_local_command("share [#{share_name}] in smb.conf", "grep -i '\\[#{share_name}\\]' /etc/samba/smb.conf", share_name)
      if storage_directory
        test_local_command('storage directory exists', "test -d #{Shellwords.escape(storage_directory)} && echo present", 'present')
      end
    end

    tier(2) do
      test_service_up(port: 445)
      # Effective configuration as samba parses it.
      test_smb_share_setting(share_name, 'guest ok', guests_allowed ? 'Yes' : 'No')
      test_smb_share_setting(share_name, 'read only', read_only ? 'Yes' : 'No')

      # The target has no smbclient (and the module must not install one), so
      # list and write as a student would, from the attacker VM.
      test_smb_share_listed(share_name, comment: share_comment)
      test_smb_anonymous_write(share_name, storage_directory, expect_writable: writable_expected) if storage_directory
    end
    # No tier 3 for this issue: the vulnerability is the anonymous write itself,
    # which tier 2 exercises from the attacker VM.
    #
    # Inputs not checked directly:
    #   strings_to_leak, leaked_filenames, images_to_leak — content planted in the share,
    #     not part of share access (mode 0666 is set by leak_files)
  end
end

SambaPublicWritableShareTest.new.run
