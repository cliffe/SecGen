#!/usr/bin/ruby
require_relative '../../../../../lib/objects/local_string_encoder.rb'
require 'securerandom'

class HexGenerator < StringEncoder
  attr_accessor :line_length
  attr_accessor :number_of_lines

  def initialize
    super
    self.module_name = 'Random Hex Generator'
    self.line_length = 0
    self.number_of_lines = 0
  end

  def encode_all
    lines = []
    num_of_lines = self.number_of_lines.to_i
    num_of_lines.times { lines << SecureRandom.hex(self.line_length) }
    self.outputs << lines.join("\n")
  end

  def process_options(opt, arg)
    super
    case opt
      when '--line_length'
        self.line_length = arg.to_i;
      when '--number_of_lines'
        self.number_of_lines = arg.to_i;
    end
  end

  def get_options_array
    super + [['--line_length', GetoptLong::REQUIRED_ARGUMENT],
             ['--number_of_lines', GetoptLong::REQUIRED_ARGUMENT]]
  end

  def encoding_print_string
    'line_length: ' + self.line_length.to_s + print_string_padding +
    'number_of_lines: ' + self.number_of_lines.to_s
  end
end

HexGenerator.new.run