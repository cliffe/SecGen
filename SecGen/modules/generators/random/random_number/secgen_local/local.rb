#!/usr/bin/ruby
require_relative '../../../../../lib/objects/local_string_generator.rb'

class NumberGenerator < StringGenerator
  attr_accessor :minimum
  attr_accessor :maximum
  attr_accessor :zero_padding

  def initialize
    super
    self.module_name = 'Random NumberGenerator'
    self.minimum = ''
    self.maximum = ''
    self.zero_padding = ''
  end

  def generate
    random_number = rand(self.minimum .. self.maximum).to_s
    random_number = random_number.to_s.rjust(self.maximum.to_s.length,'0') if self.zero_padding.downcase == "true"
    self.outputs << random_number
  end

  def process_options(opt, arg)
    super
    if opt == '--minimum'
      self.minimum = arg.to_i;
    end

    if opt == '--maximum'
      self.maximum = arg.to_i;
    end

    if opt == '--zero_padding'
      self.zero_padding = arg;
    end
  end

  def get_options_array
    super + [['--minimum', GetoptLong::REQUIRED_ARGUMENT],
             ['--maximum', GetoptLong::REQUIRED_ARGUMENT],
             ['--zero_padding', GetoptLong::OPTIONAL_ARGUMENT]]
  end

  def encoding_print_string
    'minimum: ' + self.minimum.to_s + print_string_padding +
    'maximum: ' + self.maximum.to_s + print_string_padding +
    'zero_padding: ' + self.zero_padding.to_s
  end
end

NumberGenerator.new.run