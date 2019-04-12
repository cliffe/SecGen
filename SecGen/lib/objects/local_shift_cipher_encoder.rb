#!/usr/bin/ruby
require_relative 'local_string_encoder.rb'

class ShiftCipherEncoder < StringEncoder
  attr_accessor :shift_key
  attr_accessor :highest_ascii_value

  def initialize
    super
    self.module_name = 'Caesar Cipher Encoder'
    self.shift_key = 0

    self.strings_to_encode = []
  end

  def encode(str)
    # Convert to an integer array
    shifted_string_array = []
    str.each_char { |char|
      shifted_string_array << shift(char)
    }
    shifted_string_array.join
  end

  # Override Me!
  # Takes an individual character
  # Shifts by the cypher key taking the valid range of values into account,
  # Returns the shifted character
  def shift(char)
  end

  def get_options_array
    super + [['--shift_key', GetoptLong::REQUIRED_ARGUMENT]]
  end

  def process_options(opt, arg)
    super
    if opt == '--shift_key'
      self.shift_key = arg.to_i;
    end
  end

  def encoding_print_string
    'shift_key: ' + self.shift_key.to_s + print_string_padding +
    'strings_to_encode: ' + self.strings_to_encode.to_s
  end
end