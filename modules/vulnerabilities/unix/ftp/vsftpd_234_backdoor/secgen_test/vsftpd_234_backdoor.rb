require_relative '../../../../../lib/post_provision_test'

# Post-provision test for the vsftpd 2.3.4 backdoor (OSVDB-73573,
# exploit/unix/ftp/vsftpd_234_backdoor).
#
# Tiers:
#   1  the backdoored vsftpd 2.3.4 binary is installed on the target.
#   2  the FTP daemon is listening (port 21).
#   3  a real exploit from the attacker VM achieves remote command execution.
#
# Tier 3 is the second consumer of the framework helper test_msf_exploit. In
# current Metasploit this module has no cmd/unix/interact payload (the classic
# "just run it and you get a shell" default is gone), but the no-session
# cmd/unix/generic — the helper's default, as used for distcc — is compatible
# and runs the proof-of-RCE command on the target directly. The only extra it
# needs is force: true, because the module's automatic check is inconclusive
# ("Cannot reliably check exploitability"). RCE is proven the same way as
# distcc, by a sentinel the target's own guest agent reads back. With no
# attacker system (e.g. a single-VM module run) tier 3 SKIPs.
class Vsftpd234BackdoorTest < PostProvisionTest
  def initialize
    self.module_name = 'vsftpd_234_backdoor'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super

    # Tier 1 — the self-compiled backdoored binary is in place.
    test_command_succeeds('vsftpd 2.3.4 installed', 'test -x /usr/local/sbin/vsftpd', tier: 1)

    # Tier 2 — FTP daemon listening; verify the configured banner if one was supplied.
    test_service_up(tier: 2)
    if (banner = self.json_inputs['ftpd_banner']&.first)
      test_banner(banner, tier: 2)
    end

    # Tier 3 — exploit from the attacker VM (default cmd/unix/generic payload;
    # force: because this module's automatic check is inconclusive).
    test_msf_exploit('exploit/unix/ftp/vsftpd_234_backdoor',
                     rport: self.port,
                     force: true,
                     tier: 3)
  end
end

Vsftpd234BackdoorTest.new.run
