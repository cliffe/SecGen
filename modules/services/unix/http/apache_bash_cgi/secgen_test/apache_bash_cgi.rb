require_relative '../../../../../lib/post_provision_test'

class ApacheBashCGITest < PostProvisionTest
  # The metadata declares no read_fact or default_input, so there are no inputs
  # to check. Apache itself (provided by the required apache module) serves on 80.
  def initialize
    self.module_name = 'apache_bash_cgi'
    self.module_path = get_module_path(__FILE__)
    super
    self.port = 80
  end

  def test_module
    super
    tier(1) do
      test_local_command('cgi-bin directory exists', 'test -d /usr/lib/cgi-bin && echo present', 'present')
      test_local_command('test.cgi installed', 'ls -l /usr/lib/cgi-bin/test.cgi', 'test.cgi')
      test_local_command('test.cgi is executable', 'test -x /usr/lib/cgi-bin/test.cgi && echo executable', 'executable')
      test_local_command('test.cgi is a bash script', 'head -1 /usr/lib/cgi-bin/test.cgi', '#!/bin/bash')
    end
    tier(2) do
      test_service_up
      # the script runs as the web server user and prints its response body
      test_local_command('test.cgi runs as www-data', '/usr/lib/cgi-bin/test.cgi', 'Content-type: text/plain', user: 'www-data')
      # Apache executes the script rather than serving its source
      test_http('/cgi-bin/test.cgi', match: 'Hi', label: 'CGI script executed by Apache')
    end
  end
end

ApacheBashCGITest.new.run
