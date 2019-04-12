#!/usr/bin/ruby
require_relative '../../../../../lib/objects/local_string_encoder.rb'
class L337Encoder < StringEncoder
  def initialize
    super
    self.module_name = 'L337 Encoder'
  end

  def encode(str)
    str.tr('A-Za-z', '4b-d3f6h1j-n0p-r57u-z4B-D3F6H1J-N0P-R57U-Z')
  end
end

L337Encoder.new.run
