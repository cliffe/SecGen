#!/usr/bin/ruby
require_relative '../../../../../lib/objects/local_string_generator.rb'
class Base64Generator < StringGenerator
  def initialize
    super
    self.module_name = 'Random Base64 Generator'
  end

  def generate
    require 'securerandom'
    self.outputs << SecureRandom.base64
  end
end

Base64Generator.new.run