#!/usr/bin/ruby
require_relative '../../../../../lib/objects/local_string_generator.rb'
require 'faker'

class ApplicationNameGenerator < StringGenerator
  def initialize
    super
    self.module_name = 'Application Name Generator'
  end

  def generate
    self.outputs << Faker::App.name
  end
end

ApplicationNameGenerator.new.run