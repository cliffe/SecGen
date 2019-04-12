#!/usr/bin/ruby
# Encryption algorithm code from http://rosettacode.org/wiki/Vigen%C3%A8re_cipher#Ruby
# TODO: Add difficulty: easy returns key, medium returns key length, hard doesn't return either.
require_relative '../../../../../lib/objects/local_string_encoder.rb'
class VigenereCipher < StringEncoder
  attr_accessor :encryption_key

  def initialize
    super
    self.module_name = 'Vigenere Cipher Encoder'
    self.encryption_key = ''
  end

  BASE = 'A'.ord
  SIZE = 'Z'.ord - BASE + 1

  def encrypt(text, key)
    crypt(text, key, :+)
  end

  def decrypt(text, key)
    crypt(text, key, :-)
  end

  def crypt(text, key, dir)
    text = text.upcase.gsub(/[^A-Z]/, '')
    key_iterator = key.upcase.gsub(/[^A-Z]/, '').chars.map{|c| c.ord - BASE}.cycle
    text.each_char.inject('') do |ciphertext, char|
      offset = key_iterator.next
      ciphertext << ((char.ord - BASE).send(dir, offset) % SIZE + BASE).chr
    end
  end

  # def encode_all
  #   self.strings_to_encode.each do |str|
  #     self.outputs << encrypt(str, self.encryption_key)
  #     self.outputs << "KEY: #{self.encryption_key}"
  #   end
  # end

  def encode(str)
    self.encryption_key + '_' + encrypt(str, self.encryption_key)
  end

  def process_options(opt, arg)
    super
    case opt
      # Removes any non-alphabet characters
      when '--encryption_key'
        self.encryption_key << arg.upcase.gsub(/[^A-Z]/, '');
    end
  end

  def get_options_array
    super + [['--encryption_key', GetoptLong::REQUIRED_ARGUMENT]]
  end

  def encoding_print_string
    'strings_to_encode: ' + self.strings_to_encode.to_s + print_string_padding +
    'encryption_key: ' + self.encryption_key.to_s
  end
end

VigenereCipher.new.run
