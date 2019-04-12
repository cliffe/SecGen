#!/usr/bin/ruby
require_relative '../../../../../lib/objects/local_string_encoder.rb'
class DNACipher < StringEncoder
  attr_accessor :char_map

  def initialize
    super
    self.module_name = 'DNA Cipher Encoder'
    self.strings_to_encode = []
    self.char_map = {
        'A' => 'CGA',
        'B' => 'CCA',
        'C' => 'GTT',
        'D' => 'TTG',
        'E' => 'GGC',
        'F' => 'GGT',
        'G' => 'TTT',
        'H' => 'CGC',
        'I' => 'ATG',
        'J' => 'AGT',
        'K' => 'AAG',
        'L' => 'TGC',
        'M' => 'TCC',
        'N' => 'TCT',
        'O' => 'GGA',
        'P' => 'GTG',
        'Q' => 'AAC',
        'R' => 'TCA',
        'S' => 'ACG',
        'T' => 'TTC',
        'U' => 'CTG',
        'V' => 'CCT',
        'W' => 'CCG',
        'X' => 'CTA',
        'Y' => 'AAA',
        'Z' => 'CTT',
        ' ' => 'CCC',
        ',' => 'TCG',
        '.' => 'GAT',
        ':' => 'GCT',
        '0' => 'ACT',
        '1' => 'ACC',
        '2' => 'TAG',
        '3' => 'GCA',
        '4' => 'GAG',
        '5' => 'AGA',
        '6' => 'TTA',
        '7' => 'ACA',
        '8' => 'AGG',
        '9' => 'GCG',
        '{' => '{',
        '}' => '}',
        '_' => 'ATA',
    }
  end

  def encode(str)
    encoded = []
    str.each_char do |char|
      self.char_map.key? char.upcase
      encoded << self.char_map[char.upcase]
    end
    encoded.join
  end
end

DNACipher.new.run