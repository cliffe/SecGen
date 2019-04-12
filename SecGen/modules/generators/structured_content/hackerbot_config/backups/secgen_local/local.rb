#!/usr/bin/ruby
require_relative '../../../../../../lib/objects/local_hackerbot_config_generator.rb'

class Backup < HackerbotConfigGenerator

  attr_accessor :server_ip

  def initialize
    super
    self.module_name = 'Hackerbot Config Generator Backups'
    self.title = 'Backups'

    self.local_dir = File.expand_path('../../',__FILE__)
    self.templates_path = "#{self.local_dir}/templates/"
    self.config_template_path = "#{self.local_dir}/templates/lab.xml.erb"
    self.html_template_path = "#{self.local_dir}/templates/labsheet.html.erb"

    self.server_ip = []
  end

  def get_options_array
    super + [['--server_ip', GetoptLong::REQUIRED_ARGUMENT]]
  end

  def process_options(opt, arg)
    super
    case opt
      when '--server_ip'
        self.server_ip << arg;
    end
  end

end

Backup.new.run