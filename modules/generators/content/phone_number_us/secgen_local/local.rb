#!/usr/bin/ruby
require_relative '../../../../../lib/objects/local_string_generator.rb'
require 'faker'

class PhoneNumberUSGenerator < StringGenerator
  def initialize
    super
    self.module_name = 'Random US Phone Number Generator'
  end

  def generate
    Faker::Config.locale = 'en-US'
    self.outputs << [Faker::PhoneNumber.phone_number, Faker::PhoneNumber.cell_phone].sample
  end
end

PhoneNumberUSGenerator.new.run