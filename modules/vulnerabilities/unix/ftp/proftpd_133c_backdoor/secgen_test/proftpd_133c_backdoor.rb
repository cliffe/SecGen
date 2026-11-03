require_relative '../../../../../lib/post_provision_test'

class Proftpd133cBackdoorTest < PostProvisionTest
  def initialize
    self.module_name = 'proftpd_133c_backdoor'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super
    test_service_up
    test_msf_exploit('exploit/unix/ftp/proftpd_133c_backdoor',
                     rport: self.port,
                     tier: 3)
  end
end

Proftpd133cBackdoorTest.new.run