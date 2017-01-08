#!/usr/bin/ruby
require_relative '../../../../../lib/objects/local_string_generator.rb'
require 'faker'

class ProfessionGenerator < StringGenerator
  def initialize
    super
    self.module_name = 'Profession Generator'
  end

  def generate
    self.outputs << Faker::Company.profession
  end
end

ProfessionGenerator.new.run