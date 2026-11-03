require_relative '../../../../../lib/post_provision_test'

class ApacheKaliCompatibleTest < PostProvisionTest
  # The metadata declares no read_fact or default_input, so there are no inputs
  # to check; HTTP is on the standard port 80.
  def initialize
    self.module_name = 'apache_kali_compatible'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super
    tier(1) do
      test_local_command('apache2 installed?', 'dpkg -l apache2 | grep -E "^ii"', 'apache2')
      test_local_command('apache2 binary present', 'which apache2 apache2ctl', 'apache2')
      test_local_command('default site docroot exists', 'test -d /var/www && echo present', 'present')
      # the module selects the prefork MPM
      test_local_command('prefork MPM configured', 'apache2ctl -V', 'refork')
      test_local_command('apache2 enabled at boot', 'systemctl is-enabled apache2', 'enabled')
    end
    tier(2) do
      test_service_up(port: 80)
      test_http('/', port: 80)
      test_local_command('apache config syntax', 'apache2ctl -t 2>&1', 'Syntax OK')
      # workers run as www-data, not root
      test_local_command('apache workers run as www-data', 'ps -o user= -C apache2', 'www-data')
    end
  end
end

ApacheKaliCompatibleTest.new.run
