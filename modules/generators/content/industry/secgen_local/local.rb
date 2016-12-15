#!/usr/bin/ruby
require_relative '../../../../../lib/objects/local_string_generator.rb'
require 'forgery'

class IndustryGenerator < StringGenerator
  def initialize
    super
    self.module_name = 'Industry Generator'
  end

  def generate
    self.outputs << Forgery('name').industry
  end
end

IndustryGenerator.new.run