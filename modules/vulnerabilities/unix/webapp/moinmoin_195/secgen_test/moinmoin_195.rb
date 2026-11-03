require_relative '../../../../../lib/post_provision_test'

class MoinMoin195Test < PostProvisionTest
  def initialize
    self.module_name = 'moinmoin_195'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super
    test_service_up
    test_html_returned_content('/index.html','<script type="text/javascript" src="/moin_static195/common/js/common.js"></script>')
    test_msf_exploit('exploit/unix/webapp/moinmoin_twikidraw',
                     rport: self.port,
                     tier: 3)
  end
end

MoinMoin195Test.new.run