#!/usr/bin/ruby
require_relative 'local_string_encoder.rb'
require 'digest'

class HashEncoder < StringEncoder
  attr_accessor :salt
  attr_accessor :return_salts
  attr_accessor :salt_position

  def initialize
    super
    self.module_name = 'Hash Encoder'
    self.strings_to_encode = []
    self.salt = []
    self.return_salts = false
    self.salt_position = %w(before after).sample
  end

  def hash_function(str)
  end

  def encode_all
    self.strings_to_encode.each_with_index do |string, i|

      combined_string = string

      if self.salt[i]
        if salt_position == 'before'
          combined_string = self.salt[i] + combined_string
        elsif salt_position == 'after'
          combined_string = combined_string + self.salt[i]
        end
      end

      self.outputs[i] = hash_function(combined_string)
      self.outputs[i] += "\n salt:#{self.salt[i]}" if self.return_salts
    end
  end

  def process_options(opt, arg)
    super
    if opt == '--salt'
      self.salt << arg;
    end

    if opt == '--return_salts'
      self.return_salts = (arg.to_s.downcase == 'true');
    end
  end


  def get_options_array
    super + [['--salt', GetoptLong::OPTIONAL_ARGUMENT],
             ['--return_salts', GetoptLong::OPTIONAL_ARGUMENT]]
  end

  def encoding_print_string
    print_string = 'strings_to_encode: ' + self.strings_to_encode.to_s + print_string_padding +
        'salt: ' + self.salt.to_s
    if self.salt.size > 0
      print_string += print_string_padding
      print_string += "return_salts: #{self.return_salts.to_s} #{print_string_padding}"
      print_string += "salt_position: #{self.salt_position.to_s}"
    end
    print_string
  end
end