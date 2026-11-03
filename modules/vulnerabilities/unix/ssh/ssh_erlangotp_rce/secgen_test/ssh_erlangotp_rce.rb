require_relative '../../../../../lib/post_provision_test'

class SshErlangotpRceTest < PostProvisionTest
  def initialize
    self.module_name = 'ssh_erlangotp_rce'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super
    tier(1) do
      # Vulnerable Erlang/OTP pre-built package installed (version 26.2.5.10, before CVE-2025-32433 fix)
      test_local_command('erlang/otp installed', 'test -x /usr/local/bin/erl && echo ok', 'ok')
      test_local_command('erlang-otp-ssh-rce service file present', 'test -f /etc/systemd/system/erlang-otp-ssh-rce.service && echo ok', 'ok')
    end
    tier(2) do
      # Erlang SSH daemon listens on port 2222 (default from service.pp)
      test_service_up(port: 2222)
    end
    # TODO tier 3 (exploit): deferred — CVE-2025-32433 pre-auth RCE via linux/ssh/ssh_erlangotp_rce msf module
  end
end

SshErlangotpRceTest.new.run
