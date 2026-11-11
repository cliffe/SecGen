require_relative '../../../../../lib/post_provision_test'

class ApacheWebdavUploadTest < PostProvisionTest
  def initialize
    self.module_name = 'apache_webdav_upload'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super
    # read_facts: port (via self.port everywhere) and webdav_path (the URL path
    # of the writable WebDAV collection). Both drive observable behaviour, so
    # both are read from json_inputs rather than hardcoded.
    webdav_path = self.json_inputs['webdav_path']&.first || 'webdav'
    webdav_dir  = "/var/www/webdav/#{webdav_path}"

    tier(1) do
      test_local_command('apache2 installed', 'dpkg -l apache2 | grep -E "^ii"', 'apache2')
      test_local_command('mod_dav enabled', 'ls /etc/apache2/mods-enabled/', 'dav.load')
      test_local_command('mod_dav_fs enabled', 'ls /etc/apache2/mods-enabled/', 'dav_fs.load')
      test_local_command('WebDAV collection owned by www-data',
                         "stat -c '%U' #{Shellwords.escape(webdav_dir)}", 'www-data')
    end

    tier(2) do
      test_service_up
      # An unauthenticated PUT must be accepted: mod_dav returns 201 Created for
      # a new resource. Probe locally so this proves the config, independent of
      # whether an attacker VM is present.
      probe = "#{webdav_path}/secgen_tier2_probe.txt"
      test_local_command('unauthenticated PUT accepted (HTTP 201)',
                         "curl -s -o /dev/null -w '%{http_code}' -X PUT --data-binary 'secgen-tier2-probe' " \
                         "http://127.0.0.1:#{self.port}/#{probe}",
                         '201')
      # ...and the file it wrote is then served straight back.
      test_http("/#{probe}", match: 'secgen-tier2-probe', label: 'PUT file served over GET')
    end

    # Tier 3: the MSF auxiliary uploads a file by PUT; it gives no shell, so
    # test_msf_exploit does not apply. Run the auxiliary from the attacker, then
    # prove the upload landed by fetching it back over HTTP (acceptance: the
    # file is retrievable). SKIPs cleanly when there is no attacker VM.
    tier(3) do
      sentinel_name = 'secgen_webdav_proof.txt'
      sentinel_body = 'secgen-webdav-unauth-upload-proof'
      aux = run_msf_module('auxiliary/scanner/http/http_put',
                           options: { 'RPORT'    => self.port,
                                      'PATH'     => "/#{webdav_path}/",
                                      'FILENAME' => sentinel_name,
                                      'FILEDATA' => sentinel_body },
                           label: 'webdav http_put upload')
      next unless aux

      test_http("/#{webdav_path}/#{sentinel_name}", match: sentinel_body,
                label: 'uploaded file retrievable over HTTP', tier: 3)
    end
  end
end

ApacheWebdavUploadTest.new.run
