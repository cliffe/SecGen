#!/usr/bin/ruby
require_relative '../../../../../lib/objects/local_string_encoder.rb'
require 'securerandom'

class HexEncodedDiffChallenge < StringEncoder
  attr_accessor :random_data
  attr_accessor :line_length
  attr_accessor :strings_to_leak

  def initialize
    super
    self.module_name = 'Hex Encoded Diff Challenge'
    self.random_data = ''
    self.line_length = ''
    self.strings_to_leak = []
  end

  def encode_all
    # Empty array containing the flag we want to insert - array as we might need to wrap the flag onto multiple lines.
    flag_to_insert = []

    # Create output variable containing the random data and split it into an array
    output = self.random_data.split("\n")
    input_flag = strings_to_leak[0]

    # Store lengths + wrap the flag onto multiple lines if it's longer.
    line_length = output[0].length
    flag_length = input_flag.length

    output.shuffle!

    # Handle flag wrapping to retain a consistent line length
    if flag_length < line_length
      # We need to add padding up to line_length
      padded_flag = pad_flag(input_flag, line_length - flag_length)
      flag_to_insert << padded_flag
    elsif flag_length > line_length
      # We need to split the flag at line_length, then add padding for the second line up to line_length.
      split_flag_lines = input_flag.chars.to_a.each_slice(line_length).to_a
      joined_flag_lines = split_flag_lines.each.map { |line| line.join }

      # Last element in the array will be less than the line_length so pad it then assign the padded version
      final_section = joined_flag_lines[-1]
      joined_flag_lines[-1] = pad_flag(final_section, line_length - final_section.length)
      flag_to_insert = joined_flag_lines
    else
      # If flag.length == line_length
      flag_to_insert << input_flag
    end

    # We now have an array with our flag, either one or more lines. This randomises the insertion position but retains
    # the multi-line flag data.
    random_position = rand(0..output.size-1)
    flag_to_insert.each_with_index{|flag_fragment,i|
      output.insert(random_position + i, flag_fragment)
    }

    # Add both the original random_data and the joined_output
    self.outputs << output.join("\n")
    self.outputs << self.random_data
  end

  def pad_flag (string_to_pad, size)
    string_to_pad + SecureRandom.hex(size/2)
  end

  def get_options_array
    super + [['--random_data', GetoptLong::REQUIRED_ARGUMENT],
             ['--line_length', GetoptLong::REQUIRED_ARGUMENT],
             ['--strings_to_leak', GetoptLong::REQUIRED_ARGUMENT]]
  end

  def process_options(opt, arg)
    super
    case opt
      when '--random_data'
        self.random_data << arg;
      when '--line_length'
        self.line_length << arg;
      when '--strings_to_leak'
        self.strings_to_leak << arg;
    end
  end

  def encoding_print_string
    'random_data: ' + self.random_data.to_s + print_string_padding +
    'line_length: ' + self.line_length.to_s + print_string_padding +
    'strings_to_leak: ' + self.strings_to_leak.to_s
  end
end

HexEncodedDiffChallenge.new.run