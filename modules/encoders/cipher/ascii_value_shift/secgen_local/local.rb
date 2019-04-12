#!/usr/bin/ruby
require_relative '../../../../../lib/objects/local_shift_cipher_encoder.rb'
class ASCIIValueShift < ShiftCipherEncoder
  attr_accessor :shift_key
  attr_accessor :lowest_ascii_value
  attr_accessor :highest_ascii_value

  def initialize
    super
    self.module_name = 'ASCII Value Cipher Encoder'

    self.lowest_ascii_value = 32 # value for ' '
    self.highest_ascii_value = 126 # value for '~'
  end

  def valid_ascii_range
    self.highest_ascii_value - self.lowest_ascii_value
  end

  # Converts a char into its ascii numeric value,
  # shifts by the cypher key taking the valid range of values into account,
  # returns a character
  def shift(char)
    numeric_ascii_char = char.ord
    # Only rotates characters within the valid range
    if (numeric_ascii_char >= lowest_ascii_value) && (numeric_ascii_char <= highest_ascii_value)
      base_value = (((numeric_ascii_char - lowest_ascii_value) + shift_key) % valid_ascii_range)
      shifted_value = base_value + lowest_ascii_value # Add lowest ascii value to offset the first 32 special characters
      shifted_value.chr
    end
  end
end
ASCIIValueShift.new.run
