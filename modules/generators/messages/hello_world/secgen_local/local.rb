#!/usr/bin/ruby
require_relative '../../../../../lib/objects/local_string_generator.rb'
class HelloWorldGenerator < StringGenerator
  def initialize
    super
    self.module_name = 'Hello, World! Generator'
  end

  def generate
    self.outputs << 'Hello, world!'
  end
end

HelloWorldGenerator.new.run