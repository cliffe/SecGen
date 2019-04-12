#!/usr/bin/ruby
require_relative '../../../../../lib/objects/local_string_generator.rb'
class HexGenerator < StringGenerator
  def initialize
    super
    self.module_name = 'Random Hex Generator'
  end

  def generate
    require 'securerandom'
    self.outputs << "flag{#{SecureRandom.hex}}"
  end
end

HexGenerator.new.run
