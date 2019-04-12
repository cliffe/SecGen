#!/usr/bin/ruby
require_relative 'local_string_encoder.rb'

class ParagraphGenerator < StringEncoder
  attr_accessor :paragraph_count

  def initialize
    super
    self.module_name = 'Paragraph Generator'
    self.paragraph_count = ''
  end

  def get_options_array
    super + [['--paragraph_count', GetoptLong::REQUIRED_ARGUMENT]]
  end

  def process_options(opt, arg)
    super
    if opt == '--paragraph_count'
      self.paragraph_count << arg;
    end
  end

  def encoding_print_string
    'paragraph_count: ' + self.paragraph_count.to_s
  end
end