#!/usr/bin/ruby
require_relative '../../../../../../lib/objects/local_string_generator.rb'
require 'date'

class SelectPrefetchFile < StringGenerator
  attr_accessor :selected_file_path

  def initialize
    super
    self.module_name = 'Random cat image selector'
    self.selected_file_path = Dir["#{FORENSIC_ARTEFACTS_DIR}/prefetch/*"].sample
  end

  def generate
    self.outputs << Base64.strict_encode64(self.selected_file_path)
  end
end

SelectPrefetchFile.new.run