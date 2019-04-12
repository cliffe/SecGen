#!/usr/bin/ruby
require_relative '../../../../../lib/objects/local_shift_cipher_encoder.rb'
class CaesarShiftCipher < ShiftCipherEncoder
  attr_accessor :shift_key

  def initialize
    super
    self.module_name = 'Caesar Cipher Encoder'
  end

  # Rotates a character based on alphabet position
  # shifts by the cypher key, taking case into account
  # returns a string character
  def shift(char)
    is_upper_case = /[[:upper:]]/.match(char)
    letters = ('a'..'z').to_a
    return_char = char

    if letters.include?(char.downcase)
      char_index = letters.index(char.downcase)
      shifted_index = ((char_index + shift_key) % letters.length)
      return_char = letters[shifted_index]
    end

    is_upper_case ? return_char.upcase : return_char
  end
end
CaesarShiftCipher.new.run
