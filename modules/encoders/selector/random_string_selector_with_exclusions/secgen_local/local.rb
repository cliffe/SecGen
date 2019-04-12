#!/usr/bin/ruby
require_relative '../../../../../lib/objects/local_string_encoder.rb'
class RandomSelectorExclusions < StringEncoder
  attr_accessor :exclusion_list

  def initialize
    super
    self.module_name = 'Random String Selector with Exclusions'
    self.exclusion_list = []
  end

  def encode_all
    valid_strings = strings_to_encode - exclusion_list
    self.outputs << valid_strings.sample
  end

  def process_options(opt, arg)
    super
    case opt
      # Removes any non-alphabet characters
      when '--exclusion_list'
        self.exclusion_list << arg;
    end
  end

  def get_options_array
    super + [['--exclusion_list', GetoptLong::REQUIRED_ARGUMENT]]
  end

  def encoding_print_string
    'strings_to_encode: ' + self.strings_to_encode.to_s + print_string_padding +
    'exclusion_list: ' + self.exclusion_list.to_s
  end

end

RandomSelectorExclusions.new.run
