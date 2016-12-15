#!/usr/bin/ruby
require_relative '../../../../../lib/objects/local_string_generator.rb'
require 'faker'

class CompanyMottoGenerator < StringGenerator
  def initialize
    super
    self.module_name = 'Company Motto Generator'
  end

  def generate
    self.outputs << Faker::Company.catch_phrase
  end
end

CompanyMottoGenerator.new.run