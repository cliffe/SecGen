require_relative '../../../../lib/objects/post_provision_test'

class ErlangOtpSshRceTest < PostProvisionTest
  def initialize
    @module_name = 'erlang_otp_ssh_rce'
    @module_path = 'modules/vulnerabilities/unix/misc/erlang_otp_ssh_rce'
    super
  end

  def test_erlang_installed
    result = @ssh.exec!('which erl')
    assert(!result.empty?, 'Erlang should be installed')
  end

  def test_ssh_daemon_running
    result = @ssh.exec!('ss -tlnp | grep 2222 || netstat -tlnp 2>/dev/null | grep 2222')
    assert(!result.empty?, 'Erlang SSH daemon should be listening on port 2222')
  end

  def test_vulnerability_exists
    result = @ssh.exec!('erl -eval "erlang:display(erlang:system_info(otp_release)), halt()." -noshell 2>&1')
    version = result.strip
    puts "Erlang/OTP version: #{version}"
    assert(version.match?(/^(25|26)/), "Erlang/OTP version should be vulnerable (25.x or 26.x), got: #{version}")
  end

  def test_flag_files_exist
    result = @ssh.exec!('ls -la /home/erlang_ssh/')
    assert(!result.empty?, 'Flag files should exist in /home/erlang_ssh/')
  end

  def test_beam_file_compiled
    result = @ssh.exec!('test -f /opt/erlang_ssh/ssh_daemon.beam && echo "exists"')
    assert(result.include?('exists'), 'ssh_daemon.beam should be compiled')
  end
end

ErlangOtpSshRceTest.new.run if __FILE__ == $PROGRAM_NAME