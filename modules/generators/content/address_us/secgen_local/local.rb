#!/usr/bin/ruby
require_relative '../../../../../lib/objects/local_string_generator.rb'
require 'faker'

class USAddressGenerator < StringGenerator
  def initialize
    super
    self.module_name = 'Random US Address Generator'
  end

  def generate
    street_name = [Faker::Address.street_address, Faker::Address.street_address(true)].sample
    city = Faker::Address.city
    state = Faker::Address.state
    zip_code = Faker::Address.zip

    self.outputs << street_name + ', ' + city + ', ' + state + ', ' + zip_code
  end
end

USAddressGenerator.new.run