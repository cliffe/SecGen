require_relative '../../../../../lib/post_provision_test'

class VsftpdTest < PostProvisionTest
  def initialize
    self.module_name = 'vsftpd'
    self.module_path = get_module_path(__FILE__)
    super
  end

  # Inputs: port is the only one, checked in the config and on the wire.
  # The banner, 'user' account and test files are set in vsftpd.pp, not by inputs.
  def test_module
    super
    port = self.json_inputs['port']&.first
    ftp_session = "bash -c 'exec 3<>/dev/tcp/127.0.0.1/#{port}; " \
                  "printf \"USER user\\r\\nPASS user\\r\\nPWD\\r\\nQUIT\\r\\n\" >&3; timeout 5 cat <&3'"

    tier(1) do
      test_local_command('vsftpd installed', 'dpkg -l vsftpd | grep -E "^ii"', 'vsftpd')
      test_local_command('vsftpd binary present', 'test -x /usr/sbin/vsftpd && echo present', 'present')
      test_local_command('vsftpd.conf listen_port', 'grep -E "^listen_port=" /etc/vsftpd.conf', "listen_port=#{port}") if port
      test_local_command('anonymous login disabled', 'grep -E "^anonymous_enable=" /etc/vsftpd.conf', 'anonymous_enable=NO')
      test_local_command('local logins enabled', 'grep -E "^local_enable=" /etc/vsftpd.conf', 'local_enable=YES')
      test_local_command('configured banner in vsftpd.conf', 'grep -E "^ftpd_banner=" /etc/vsftpd.conf', 'Hello, welcome to this vsftpd server!')
      # the FTP account and its files created by the module
      test_local_command('ftp user exists', 'id user', 'uid=')
      test_local_command('test files in /home/user', 'ls -R /home/user', 'testfile')
      test_local_command('test dir content', 'ls /home/user/testdir', 'test')
      test_local_command('vsftpd enabled at boot', 'systemctl is-enabled vsftpd', 'enabled')
    end

    tier(2) do
      test_service_up
      # banner set by vsftpd.pp (ftpd_banner); proves vsftpd (not another FTP daemon) answers
      test_banner('Hello, welcome to this vsftpd server!', label: 'FTP banner')
      # a local user can authenticate (anonymous is off, local_enable is on)
      test_local_command('local user logs in over FTP', ftp_session, '230') if port
      test_local_command('anonymous login refused', "bash -c 'exec 3<>/dev/tcp/127.0.0.1/#{port}; printf \"USER anonymous\\r\\nPASS a@b\\r\\nQUIT\\r\\n\" >&3; timeout 5 cat <&3'", '530') if port
    end
  end
end

VsftpdTest.new.run
