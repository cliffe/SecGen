#!/usr/bin/ruby
require_relative '../../../../../lib/objects/local_string_encoder.rb'
class HexEncoder < StringEncoder
  def initialize
    super
    self.module_name = 'Hexadecimal Encoder'
  end

  def encode(str)
    encoded_char_array = []
    str.each_char { |char| encoded_char_array << char.ord.to_s(16) }
    encoded_char_array.join
  end
end

HexEncoder.new.run
