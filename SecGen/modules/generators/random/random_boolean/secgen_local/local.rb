#!/usr/bin/ruby
require_relative '../../../../../lib/objects/local_string_generator.rb'

class BooleanGenerator < StringGenerator
  def initialize
    super
    self.module_name = 'Random Boolean Generator'
  end

  def generate
    self.outputs << [true, false].sample.to_s
  end
end

BooleanGenerator.new.run