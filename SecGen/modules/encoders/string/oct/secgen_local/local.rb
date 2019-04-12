#!/usr/bin/ruby
require_relative '../../../../../lib/objects/local_string_encoder.rb'
class OctalEncoder < StringEncoder
  def initialize
    super
    self.module_name = 'Octal Encoder'
  end

  def encode(str)
    encoded_char_array = []
    str.each_char { |char|
      converted_char = char.ord.to_s(8)

      # Pad with leading 0s
      if converted_char.length == 1
        converted_char = "00#{converted_char}"
      elsif converted_char.length == 2
        converted_char = "0#{converted_char}"
      end

      encoded_char_array << converted_char
    }
    encoded_char_array.join
  end
end

OctalEncoder.new.run
