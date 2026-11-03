require_relative '../../../../../lib/post_provision_test'

class NcBackdoorTest < PostProvisionTest
  def initialize
    self.module_name = 'nc_message'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super
    leak_file = "/root/cronncatmsg#{self.port}"
    strings = json_inputs['strings_to_leak'] || []
    tier(1) do
      test_local_command('ncat/nc present', 'which ncat || which nc', 'nc')
      test_command_succeeds('leak file present', "test -f #{leak_file}")
      # strings_to_leak: everything configured to be served is written into the leak file
      strings.each_with_index do |s, i|
        test_local_command("strings_to_leak[#{i}] in leak file", "cat #{leak_file}", s)
      end
      # the listener is started via a reboot cron job, on the configured port
      test_local_command('cron runs ncat on reboot', 'crontab -l', "ncat -l -p #{self.port}")
    end
    tier(2) do
      test_service_up
      # connecting to the port actually serves the configured message, proving the cron job ran ncat for real
      strings.each_with_index do |s, i|
        test_banner(s, label: "connecting returns strings_to_leak[#{i}]")
      end
    end
  end
end

NcBackdoorTest.new.run
