#!/usr/bin/ruby
require 'json'
require 'time'
require_relative '../../../../../lib/objects/local_string_encoder.rb'

class DateGenerator < StringEncoder
  attr_accessor :format
  attr_accessor :date

  def initialize
    super
    self.module_name = 'Date Generator'
    self.format = ''
    self.date = ''
  end

  def encode_all
    if self.date != ''
      date = self.date.split(' ')[0]
      time = self.date.split(' ')[1]
      day = date.split('/')[0]
      month = date.split('/')[1]
      year = date.split('/')[2]
      hour = time.split(':')[0]
      minutes = time.split(':')[1]
      seconds = time.split(':')[2]
      output_date = Time.new(year,month,day,hour,minutes,seconds)
    else
      output_date = Time.at(rand * Time.now.to_i)
    end

    if format == 'mysql_datetime'
      output_date = output_date.strftime('%Y-%m-%d %H:%M:%S')
    elsif format == 'mail'
      output_date = output_date.strftime('%a %b %d %H:%M:%S %Y')
    end

    self.outputs << output_date
  end

  def get_options_array
    super + [['--format', GetoptLong::REQUIRED_ARGUMENT],
             ['--date', GetoptLong::OPTIONAL_ARGUMENT]]
  end

  def process_options(opt, arg)
    super
    case opt
      when '--format'
        self.format << arg;
      when '--date'
        self.date << arg;
    end
  end

  def encoding_print_string
    'format: ' + self.format.to_s + print_string_padding +
    'date: ' + self.date.to_s
  end
end

DateGenerator.new.run
