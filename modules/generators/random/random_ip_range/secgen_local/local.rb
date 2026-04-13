#!/usr/bin/ruby
require_relative '../../../../../lib/objects/local_string_generator.rb'

class IPRangeGenerator < StringGenerator
  def initialize
    super
    self.module_name = 'Random IP Range Generator'
  end

  def generate
    self.outputs << "10.#{rand(256)}.0.0"
  end
end

IPRangeGenerator.new.run