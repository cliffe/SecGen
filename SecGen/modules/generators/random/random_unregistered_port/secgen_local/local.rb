#!/usr/bin/ruby
require_relative '../../../../../lib/objects/local_string_generator.rb'
class PortGenerator < StringGenerator

  def initialize
    super
    self.module_name = 'Random Unregistered Port'
  end

  def generate
    self.outputs << rand(1025..65535).to_s
  end
end

PortGenerator.new.run
