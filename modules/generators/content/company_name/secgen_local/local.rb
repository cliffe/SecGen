#!/usr/bin/ruby
require_relative '../../../../../lib/objects/local_string_generator.rb'
require 'faker'

class CompanyNameGenerator < StringGenerator
  def initialize
    super
    self.module_name = 'Company Name Generator'
  end

  def generate
    self.outputs << Faker::Company.name
  end
end

CompanyNameGenerator.new.run