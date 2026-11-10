#!/usr/bin/ruby
require_relative '../../../../../../lib/objects/local_hackerbot_config_generator.rb'

class AiBackdoor < HackerbotConfigGenerator
  attr_accessor :lab_params

  def initialize
    super
    self.module_name = 'Hackerbot Config Generator AI Backdoor'
    self.title = 'Data poisoning and backdoors'
    self.local_dir = File.expand_path('../../', __FILE__)
    self.templates_path = "#{self.local_dir}/templates/"
    self.config_template_path = "#{self.local_dir}/templates/lab.xml.erb"
    self.lab_params = []
  end

  def get_options_array
    super + [['--lab_params', GetoptLong::REQUIRED_ARGUMENT]]
  end

  def process_options(opt, arg)
    super
    self.lab_params << arg if opt == '--lab_params'
  end
end

AiBackdoor.new.run
