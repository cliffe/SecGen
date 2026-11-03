require_relative '../../../../../lib/post_provision_test'

class ApacheCouchdbTest < PostProvisionTest
  def initialize
    self.module_name = 'apache_couchdb'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super
    username = self.json_inputs['unix_username']&.first

    tier(1) do
      test_local_command('couchdb installed?', 'dpkg -l couchdb | grep -E "^ii"', 'couchdb')
      if username
        test_local_command("#{username} user exists", "id #{username}", username)
      end
    end
    tier(2) do
      test_service_up
      test_http('/', match: 'couchdb')
    end
    # TODO tier 3 (exploit): deferred — wire up test_msf_exploit when attacker VM is available
    # msf_module: exploit/multi/http/apache_couchdb_erlang_rce (CVE-2022-24706)
  end
end

ApacheCouchdbTest.new.run
