require_relative '../../../../../lib/post_provision_test'

class ErgochatTest < PostProvisionTest
  def initialize
    self.module_name = 'ergochat'
    self.module_path = get_module_path(__FILE__)
    super
    self.port = 6667
  end

  def test_module
    super
    test_service_up
  end
end

ErgochatTest.new.run
