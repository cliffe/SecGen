#!/usr/bin/ruby
require_relative '../../../../../../lib/objects/local_hackerbot_config_generator.rb'

class REMACoconut < HackerbotConfigGenerator

  attr_accessor :desktop_ip
  attr_accessor :hackerbot_server_ip
  attr_accessor :victim_server_ip
  attr_accessor :coconut_config

  def initialize
    super
    self.module_name = 'Hackerbot Config Generator REMA Coconut'
    self.title = 'REMA Coconut'

    self.local_dir = File.expand_path('../../', __FILE__)
    self.templates_path = "#{self.local_dir}/templates/"
    self.config_template_path = "#{self.local_dir}/templates/rema_coconut.xml.erb"
    self.html_template_path = "#{self.local_dir}/templates/labsheet.html.erb"
    self.desktop_ip = ''
    self.hackerbot_server_ip = ''
    self.victim_server_ip = ''
    self.coconut_config = ''
  end

  def get_options_array
    super + [['--desktop_ip', GetoptLong::REQUIRED_ARGUMENT],
             ['--coconut_config', GetoptLong::REQUIRED_ARGUMENT],
             ['--victim_server_ip', GetoptLong::REQUIRED_ARGUMENT],
             ['--hackerbot_server_ip', GetoptLong::REQUIRED_ARGUMENT]]
  end

  def process_options(opt, arg)
    super
    case opt
      when '--desktop_ip'
        self.desktop_ip << arg;
      when '--hackerbot_server_ip'
        self.hackerbot_server_ip << arg;
      when '--victim_server_ip'
        self.victim_server_ip << arg;
      when '--coconut_config'
        self.coconut_config << arg;
    end
  end
end

REMACoconut.new.run