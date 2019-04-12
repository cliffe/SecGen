#!/usr/bin/ruby
require_relative '../../../../../../lib/objects/local_hackerbot_config_generator.rb'

class HBC < HackerbotConfigGenerator

  attr_accessor :compromised_server_ip
  attr_accessor :hackerbot_server_ip
  attr_accessor :hidden_port
  attr_accessor :hidden_string

  def initialize
    super
    self.module_name = 'Hackerbot Config Generator Live'
    self.title = 'Live Analysis'

    self.local_dir = File.expand_path('../../',__FILE__)
    self.templates_path = "#{self.local_dir}/templates/"
    self.config_template_path = "#{self.local_dir}/templates/lab.xml.erb"
    self.html_template_path = "#{self.local_dir}/templates/labsheet.html.erb"

    self.compromised_server_ip = []
    self.hackerbot_server_ip = []
    self.hidden_port = []
    self.hidden_string = []
  end

  def get_options_array
    super + [['--compromised_server_ip', GetoptLong::REQUIRED_ARGUMENT],
             ['--hackerbot_server_ip', GetoptLong::REQUIRED_ARGUMENT],
             ['--hidden_port', GetoptLong::REQUIRED_ARGUMENT],
             ['--hidden_string', GetoptLong::REQUIRED_ARGUMENT]]
  end

  def process_options(opt, arg)
    super
    case opt
      when '--compromised_server_ip'
        self.compromised_server_ip << arg;
      when '--hackerbot_server_ip'
        self.hackerbot_server_ip << arg;
      when '--hidden_port'
        self.hidden_port << arg;
      when '--hidden_string'
        self.hidden_string << arg;
    end
  end

end

HBC.new.run
