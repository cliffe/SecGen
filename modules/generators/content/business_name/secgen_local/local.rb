#!/usr/bin/ruby
require_relative '../../../../../lib/objects/local_string_generator.rb'
require 'faker'

class BusinessNameGenerator < StringGenerator
  def initialize
    super
    self.module_name = 'Business Name Generator'
  end

  def generate
    self.outputs << Faker::Company.name
  end
end

BusinessNameGenerator.new.run