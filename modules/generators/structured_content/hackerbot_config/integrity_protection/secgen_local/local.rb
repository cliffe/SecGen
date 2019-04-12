#!/usr/bin/ruby
require_relative '../../../../../../lib/objects/local_hackerbot_config_generator.rb'

class Integrity1 < HackerbotConfigGenerator

  def initialize
    super
    self.module_name = 'Hackerbot Config Generator Integrity'
    self.title = 'Integrity management: protecting integrity'

    self.local_dir = File.expand_path('../../',__FILE__)
    self.templates_path = "#{self.local_dir}/templates/"
    self.config_template_path = "#{self.local_dir}/templates/integrity_lab.xml.erb"
    self.html_template_path = "#{self.local_dir}/templates/labsheet.html.erb"
  end

end

Integrity1.new.run