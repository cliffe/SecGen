require_relative '../../../../../lib/post_provision_test'

class HackerbotClientTest < PostProvisionTest
  def initialize
    self.module_name = 'hackerbot_client'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super
    # ssh_key_pair is a JSON string holding the 'public' (and 'private') key; only the public key lands on this box
    public_key = begin
      JSON.parse(self.json_inputs['ssh_key_pair']&.first.to_s)['public'].to_s.strip
    rescue JSON::ParserError
      ''
    end

    tier(1) do
      test_local_command('/root/.ssh directory exists', 'test -d /root/.ssh && echo ok', 'ok')
      test_local_command('authorized_keys present', 'test -f /root/.ssh/authorized_keys && echo ok', 'ok')
      test_local_command('/root/.ssh is root-owned mode 700', "stat -c '%U:%G %a' /root/.ssh", 'root:root 700')
      test_local_command('authorized_keys is root-owned mode 600', "stat -c '%U:%G %a' /root/.ssh/authorized_keys", 'root:root 600')
      # the supplied public key is installed
      test_local_command('authorized_keys holds the supplied public key', 'cat /root/.ssh/authorized_keys', public_key) unless public_key.empty?
    end
    tier(2) do
      # The file must be non-empty and contain a public key injected by hackerbot
      test_local_command('authorized_keys non-empty', 'test -s /root/.ssh/authorized_keys && echo ok', 'ok')
      test_local_command('authorized_keys has ssh key', "grep -qE '^(ssh-rsa|ssh-ed25519|ecdsa)' /root/.ssh/authorized_keys && echo ok", 'ok')
      # ssh-keygen parses the installed key and reports a fingerprint
      test_local_command('authorized_keys parses as a key', 'ssh-keygen -l -f /root/.ssh/authorized_keys', 'SHA256:')
      # sshd accepts the effective config (root login by key is what the lab relies on)
      test_local_command('sshd config valid and allows key login', 'sshd -T 2>&1', 'pubkeyauthentication yes')
    end
  end
end

HackerbotClientTest.new.run
