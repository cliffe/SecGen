#!/usr/bin/ruby
require_relative '../../../../../lib/objects/local_string_generator.rb'

class LineGenerator < StringGenerator
  attr_accessor :linelist

  def initialize
    super
    self.linelist = []
    self.module_name = 'Random Word Generator'
  end

  def get_options_array
    super + [['--linelist', GetoptLong::OPTIONAL_ARGUMENT]]
  end

  def process_options(opt, arg)
    super
    case opt
    when '--linelist'
        self.linelist << arg;
    end
  end

  def generate
    # read all the lines, and select one at random
    line = File.readlines("#{LINELISTS_DIR}/#{self.linelist.sample.chomp}").sample.chomp
    # strip out everything except alphanumeric and basic punctuation (no ' or ")
    self.outputs << line.gsub(/[^\w !.,]/, '')
  end
end

LineGenerator.new.run
