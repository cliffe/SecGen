require_relative '../../../../lib/objects/post_provision_test'

class SshErlangotpRceTest < PostProvisionTest
  def initialize
    @module_name = 'ssh_erlangotp_rce'
    @module_path = 'modules/vulnerabilities/unix/misc/ssh_erlangotp_rce'
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
    assert(version.include?('26'), "Erlang/OTP version should be vulnerable 26.x, got: #{version}")
  end

  def test_flag_files_exist
    daemon_user = @ssh.exec!("ps -eo user,cmd | awk '/start_ssh\\.escript/ && !/awk/ {print $1; exit}'").strip
    result = @ssh.exec!("ls -la /home/#{daemon_user}/")
    assert(!result.empty?, "Flag files should exist in /home/#{daemon_user}/")
  end

  def test_start_script_exists
    result = @ssh.exec!('test -x /opt/erlang_ssh/start_ssh.escript && echo "exists"')
    assert(result.include?('exists'), 'start_ssh.escript should exist and be executable')
  end
end

SshErlangotpRceTest.new.run if __FILE__ == $PROGRAM_NAME