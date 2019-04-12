#!/usr/bin/ruby
require_relative '../../../../../lib/objects/local_string_generator.rb'
require 'faker'

class UKAddressGenerator < StringGenerator
  def initialize
    super
    self.module_name = 'Random UK Address Generator'
  end

  def generate
    Faker::Config.locale = 'en-GB'

    street_name = Faker::Address.street_address
    city = Faker::Address.city
    county = Faker::Address.county
    postcode = Faker::Address.postcode

    self.outputs << street_name + ', ' + city + ', ' + county + ', ' + postcode
  end
end

UKAddressGenerator.new.run