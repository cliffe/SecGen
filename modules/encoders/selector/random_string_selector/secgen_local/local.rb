#!/usr/bin/ruby
require_relative '../../../../../lib/objects/local_string_encoder.rb'
class RandomSelectorEncoder < StringEncoder
  attr_accessor :position

  def initialize
    super
    self.module_name = 'Random String Selector'
    self.position = ''
  end

  def encode_all
    selected_string = ''
    if self.position != nil and self.position != ''
      selected_string = self.strings_to_encode[self.position.to_i - 1]
    else
      selected_string = self.strings_to_encode.sample
    end
    self.outputs << selected_string
  end

  def process_options(opt, arg)
    super
    case opt
      # Removes any non-alphabet characters
      when '--position'
        self.position << arg;
    end
  end

  def get_options_array
    super + [['--position', GetoptLong::OPTIONAL_ARGUMENT]]
  end

  def encoding_print_string
    string = "strings_to_encode: #{self.strings_to_encode.to_s}"
    if self.position.to_s.length > 0
     string += print_string_padding + "position: #{self.position.to_s}"
    end
     string
  end

end

RandomSelectorEncoder.new.run
