#!/usr/bin/ruby
require_relative '../../../../../lib/objects/local_string_encoder.rb'
class MorseCodeEncoder < StringEncoder
  attr_accessor :morse_code_hash

  def initialize
    super
    self.module_name = 'Morse Code Encoder'
    self.strings_to_encode = []

    self.morse_code_hash = {'a' => '.-',
                            'b' => '-...',
                            'c' => '-.-.',
                            'd' => '-..',
                            'e' => '.',
                            'f' => '..-.',
                            'g' => '--.',
                            'h' => '....',
                            'i' => '..',
                            'j' => '.---',
                            'k' => '-.-',
                            'l' => '.-..',
                            'm' => '--',
                            'n' => '-.',
                            'o' => '---',
                            'p' => '.--.',
                            'q' => '--.-',
                            'r' => '.-.',
                            's' => '...',
                            't' => '-',
                            'u' => '..-',
                            'v' => '...-',
                            'w' => '.--',
                            'x' => '-..-',
                            'y' => '-.--',
                            'z' => '--..',
                            ' ' => '/',
                            '1' => '.----',
                            '2' => '..---',
                            '3' => '...--',
                            '4' => '....-',
                            '5' => '.....',
                            '6' => '-....',
                            '7' => '--...',
                            '8' => '---..',
                            '9' => '----.',
                            '0' => '-----',
                            '.' => '.-.-.-',
                            ',' => '--..--',
                            ':' => '---...',
                            '?' => '..--..',
                            '\'' => '.----.',
                            '-' => '-....-',
                            '/' => '-..-.',
                            '(' => '-.--.-',
                            ')' => '-.--.-',
                            '[' => '-.--.-',
                            ']' => '-.--.-',
                            '<' => '-.--.-',
                            '>' => '-.--.-',
                            '{' => '-.--.-',
                            '}' => '-.--.-',
                            '"' => '.-..-.',
                            '@' => '.--.-.',
                            '=' => '-...-',
    }
  end

  def encode(str)
    morse_string = ''
    str.each_char { |char|
      # if the character is in the hash convert it. if not, drop the character.
      if morse_code_hash.key? char.downcase
        morse_string << morse_code_hash[char.downcase] + ' '
      end
    }
    morse_string
  end
end
MorseCodeEncoder.new.run
