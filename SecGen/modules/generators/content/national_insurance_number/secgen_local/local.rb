#!/usr/bin/ruby
require_relative '../../../../../lib/objects/local_string_generator.rb'

class NINGenerator < StringGenerator
  def initialize
    super
    self.module_name = 'National Insurance Number Generator'
  end

  def generate
    nino = "QQ"<<(10..99).to_a.sample(3)*''<<("A".."D").to_a.sample

    self.outputs << nino
  end
end

NINGenerator.new.run