#!/usr/bin/ruby
require_relative '../../../../../lib/objects/local_string_generator.rb'
require 'faker'
require 'forgery'

class NameGenerator < StringGenerator
  def initialize
    super
    self.module_name = 'Random Name Generator'
  end

  def generate
    self.outputs << [Faker::Name.name, Forgery::Name.full_name].sample
  end
end

NameGenerator.new.run