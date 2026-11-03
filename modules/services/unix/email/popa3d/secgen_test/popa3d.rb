require_relative '../../../../../lib/post_provision_test'

class Popa3dTest < PostProvisionTest
  # The metadata declares no read_fact or default_input, so there are no inputs
  # to check; POP3 is on the standard port 110.
  def initialize
    self.module_name = 'popa3d'
    self.module_path = get_module_path(__FILE__)
    super
    self.port = 110
  end

  def test_module
    super
    # Tier 1: package installed (Debian ships the daemon at /usr/sbin/popa3d)
    test_local_command('popa3d package installed', 'dpkg -l popa3d | grep -E "^ii"', 'popa3d', tier: 1)
    test_command_succeeds('popa3d binary installed', 'test -x /usr/sbin/popa3d', tier: 1)
    # Tier 2: daemon listening (standalone mode is the debconf default) and greets with POP3 +OK
    test_service_up
    test_banner('+OK', label: 'POP3 greeting from popa3d')
    test_local_command('popa3d process running', 'ps -ef | grep popa3d', '/usr/sbin/popa3d', tier: 2)
    # a login attempt as a user that does not exist reaches the authentication code and is refused
    bad_login = "bash -c 'exec 3<>/dev/tcp/127.0.0.1/#{self.port}; " \
                "printf \"USER nosuchuser\\r\\nPASS wrong\\r\\nQUIT\\r\\n\" >&3; timeout 5 cat <&3'"
    test_local_command('popa3d refuses an unknown user', bad_login, '-ERR', tier: 2)
  end
end

Popa3dTest.new.run
