#!/usr/bin/ruby
require_relative '../../../../../../lib/objects/local_hackerbot_config_generator.rb'

class NetworksIntro < HackerbotConfigGenerator
  attr_accessor :ip_addresses

  def initialize
    super
    self.module_name = 'Hackerbot Config Generator Networks Intro'
    self.title = 'Network Security Fundamentals: Network Design, Segmentation, NAT & DMZ'

    self.local_dir = File.expand_path('../../',__FILE__)
    self.templates_path = "#{self.local_dir}/templates/"
    self.config_template_path = "#{self.local_dir}/templates/lab.xml.erb"
    self.html_template_path = "#{self.local_dir}/templates/labsheet.html.erb"

    self.ip_addresses = []
  end
  def get_options_array
    super + [['--ip_addresses', GetoptLong::REQUIRED_ARGUMENT]]
  end

  def process_options(opt, arg)
    super
    case opt
      when '--ip_addresses'
        self.ip_addresses << arg;
      end
  end
end

NetworksIntro.new.run