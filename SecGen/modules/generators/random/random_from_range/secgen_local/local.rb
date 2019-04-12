#!/usr/bin/ruby
require_relative '../../../../../lib/objects/local_string_encoder.rb'
class RangeEncoder < StringEncoder
  attr_accessor :lower_bound
  attr_accessor :upper_bound

  def initialize
    super
    self.module_name = 'Random Range Selector'
    self.lower_bound = ''
    self.upper_bound = ''
  end

  def encode_all
    self.outputs << rand(lower_bound.to_i .. upper_bound.to_i).to_s
  end

  def get_options_array
    super + [['--lower_bound', GetoptLong::REQUIRED_ARGUMENT],
             ['--upper_bound', GetoptLong::REQUIRED_ARGUMENT]]
  end

  def process_options(opt, arg)
    super
    case opt
      when '--lower_bound'
        self.lower_bound << arg;
      when '--upper_bound'
        self.upper_bound << arg;
    end
  end

  def encoding_print_string
    'random number from range(' + self.lower_bound + ' .. ' + self.upper_bound + ')'
  end
end

RangeEncoder.new.run
