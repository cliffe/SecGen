require_relative '../../../../../lib/post_provision_test'

class Proftpd133cBackdoorTest < PostProvisionTest
  # The service user proftpd drops to in this (nonroot) variant. The daemon is
  # started --chuid to this user and the config's global `User` directive names
  # it, so exploiting the pre-auth backdoor lands a shell as this user, not root
  # (the sibling proftpd_133c_backdoor is the root_rwx variant). Hardcoded as
  # $deploy_user in manifests/config.pp, not a read_fact, so it is fixed here.
  SERVICE_USER = 'ftp'.freeze

  def initialize
    self.module_name = 'proftpd_133c_backdoor_nonroot'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super
    tier(1) { test_command_succeeds('proftpd installed', 'test -x /usr/local/sbin/proftpd') }

    tier(2) do
      test_service_up
      if (server_name = self.json_inputs['server_name']&.first)
        test_banner(server_name)
      end

      # Nonroot variant: proftpd must be configured to run as the non-root
      # service user, and the sibling's `User root` must be absent.
      test_command_succeeds(
        "proftpd configured to run as non-root user #{SERVICE_USER}",
        "grep -Eq '^[[:space:]]*User[[:space:]]+#{SERVICE_USER}([[:space:]]|$)' /etc/proftpd/proftpd.conf && " \
          "! grep -Eq '^[[:space:]]*User[[:space:]]+root([[:space:]]|$)' /etc/proftpd/proftpd.conf")

      # The service user must not have sudo access, so a shell as it is not a
      # trivial route to root (checks sudo-granting groups and sudo -l).
      test_command_succeeds(
        "service user #{SERVICE_USER} has no sudo access",
        "u=#{SERVICE_USER}; " \
          "in_grp=$(id -nG \"$u\" 2>/dev/null | tr ' ' '\\n' | grep -Exc 'sudo|admin|wheel'); " \
          "listed=0; command -v sudo >/dev/null 2>&1 && " \
          "listed=$(sudo -n -l -U \"$u\" 2>/dev/null | grep -Ec '^[[:space:]]*\\('); " \
          "[ \"$in_grp\" -eq 0 ] && [ \"$listed\" -eq 0 ]")
    end

    # Tier 3: the backdoor must give RCE and, because this module declares
    # <privilege>user_rwx, land as a non-root, non-sudoer shell. expect_privilege
    # makes test_msf_exploit assert that from the sentinel's id/sudo output.
    test_msf_exploit('exploit/unix/ftp/proftpd_133c_backdoor',
                     rport: self.port,
                     expect_privilege: 'user_rwx',
                     tier: 3)
  end
end

Proftpd133cBackdoorTest.new.run
