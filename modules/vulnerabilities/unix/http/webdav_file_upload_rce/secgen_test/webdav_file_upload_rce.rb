require 'shellwords'
require_relative '../../../../../lib/post_provision_test'

# The meta-module declares no resources; the writable collection and the chosen
# execution enabler are tested by their own secgen_tests. This test only confirms
# that the composition resolved on the host: a WebDAV collection exists and
# exactly one execution method (PHP or CGI) is enabled. The end-to-end exploit is
# proven at tier 3 by whichever enabler was selected.
class WebdavFileUploadRceTest < PostProvisionTest
  def initialize
    self.module_name = 'webdav_file_upload_rce'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super

    tier(1) do
      test_local_command('Apache installed', 'dpkg -l apache2 2>/dev/null | grep -E "^ii"', 'apache2')
      test_local_command('writable WebDAV collection present',
                         'find /var/www/webdav -mindepth 1 -maxdepth 1 -type d -user www-data 2>/dev/null',
                         '/var/www/webdav/')

      php = run_command('apache2ctl -M 2>/dev/null | grep -c php')[:stdout].to_s.strip.to_i > 0
      cgi = run_command('test -f /etc/apache2/conf.d/webdav-cgi-exec.conf && echo yes')[:stdout].to_s.include?('yes')

      if php ^ cgi
        pass_check('exactly one execution method enabled',
                   "Composition resolved with #{php ? 'PHP (mod_php)' : 'CGI (mod_actions dispatcher)'}.", tier: 1)
      else
        fail_check('exactly one execution method enabled',
                   "Expected exactly one of PHP/CGI; php=#{php} cgi=#{cgi}.", tier: 1)
      end
    end
  end
end

WebdavFileUploadRceTest.new.run
