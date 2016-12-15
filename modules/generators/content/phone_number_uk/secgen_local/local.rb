#!/usr/bin/ruby
require_relative '../../../../../lib/objects/local_string_generator.rb'
require 'faker'

class PhoneNumberUKGenerator < StringGenerator
  def initialize
    super
    self.module_name = 'Random UK Phone Number Generator'
  end

  def generate
    Faker::Config.locale = 'en-GB'
    self.outputs << [Faker::PhoneNumber.phone_number, Faker::PhoneNumber.cell_phone].sample
  end
end

PhoneNumberUKGenerator.new.run