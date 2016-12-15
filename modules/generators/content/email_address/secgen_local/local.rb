#!/usr/bin/ruby
require_relative '../../../../../lib/objects/local_string_generator.rb'
require 'faker'

class EmailAddressGenerator < StringGenerator
  def initialize
    super
    self.module_name = 'Random Email Address Generator'
  end

  def generate
    self.outputs << Faker::Internet.email
  end
end

EmailAddressGenerator.new.run