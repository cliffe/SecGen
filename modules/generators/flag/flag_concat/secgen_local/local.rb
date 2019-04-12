#!/usr/bin/ruby
require_relative '../../../../../lib/objects/local_string_encoder.rb'
class ConcatFlagGenerator < StringEncoder
  attr_accessor :strings_to_join

  def initialize
    super
    self.module_name = 'Concat Flag Generator'
    self.strings_to_join = []
  end

  def encode_all
    contents = self.strings_to_join.join(' ')
    self.outputs << "flag{#{contents}}"
  end

  def get_options_array
    super + [['--strings_to_join', GetoptLong::REQUIRED_ARGUMENT]]
  end

  def process_options(opt, arg)
    super
    case opt
      when '--strings_to_join'
        self.strings_to_join << arg;
    end
  end

  def encoding_print_string
    'strings_to_join: ' + self.strings_to_join.to_s
  end
end

ConcatFlagGenerator.new.run
