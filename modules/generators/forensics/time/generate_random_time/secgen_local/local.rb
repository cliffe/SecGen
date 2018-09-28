#!/usr/bin/ruby
require_relative '../../../../../../lib/objects/local_string_generator.rb'
require 'time'

class GenerateRandomTime < StringGenerator
  attr_accessor :date_start
  attr_accessor :date_end

  def initialize
    super
    self.module_name = 'Random date generator'
    self.date_start = ''
    self.date_end = ''
  end

  def get_options_array
    super + [['--date_start', GetoptLong::OPTIONAL_ARGUMENT],
             ['--date_end', GetoptLong::OPTIONAL_ARGUMENT]]
  end

  def process_options(opt, arg)
    super
    case opt
      when '--date_start'
        self.date_start << arg;
      when '--date_end'
        self.date_end << arg;
    end
  end

  def generate
    self.date_start.empty? ? self.date_start = 0.0: self.date_start = Time.parse(self.date_start)
    self.date_end.empty? ? self.date_end = Time.now: self.date_end = Time.parse(self.date_end)

    random_date = Time.at(self.date_start.to_f + rand * (self.date_end.to_f - self.date_start.to_f))
    self.outputs << random_date.strftime("%m/%d/%Y %H:%M:%S")
  end
end

GenerateRandomTime.new.run