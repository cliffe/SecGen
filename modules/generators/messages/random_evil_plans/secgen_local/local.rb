#!/usr/bin/ruby
require 'base64'
require_relative '../../../../../lib/objects/local_string_generator.rb'
class EvilPlansGenerator < StringGenerator
  def initialize
    super
    self.module_name = 'Random Evil Plans File Generator'
  end

  def generate
    selected_path = Dir["#{EVIL_PLANS_DIR}/*"].sample
    self.outputs << File.read(selected_path)
  end
end

EvilPlansGenerator.new.run
