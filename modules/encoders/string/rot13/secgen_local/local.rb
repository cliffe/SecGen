#!/usr/bin/ruby
require_relative '../../../../../lib/objects/local_string_encoder.rb'
class ROT13Encoder < StringEncoder
  def initialize
    super
    self.module_name = 'ROT13 Encoder'
  end

  def encode(str)
    str.tr('A-Za-z', 'N-ZA-Mn-za-m')
  end
end

ROT13Encoder.new.run
