#!/usr/bin/ruby
require_relative '../../../../../lib/objects/local_string_encoder.rb'
class ConcatParagraphGenerator < StringEncoder
  attr_accessor :data
  attr_accessor :separator

  def initialize
    super
    self.module_name = 'Concatenated Paragraph Generator'
    self.data = []
    self.separator = ""
  end

  def encode_all
    # sort out separator special characters
    self.separator.gsub!('\t', "\t")
    self.separator.gsub!('\n', "\n")

    paragraph = ""

    self.data.each do |string|
      paragraph += string + self.separator
    end

    self.outputs << paragraph
  end

  def get_options_array
    super + [['--data', GetoptLong::REQUIRED_ARGUMENT],
             ['--separator', GetoptLong::REQUIRED_ARGUMENT]]
  end

  def process_options(opt, arg)
    super
    case opt
      when '--data'
        self.data<< arg;
      when '--separator'
        self.separator<< "#{arg}";
    end
  end


  def encoding_print_string
    'data: ' + self.data.to_s + print_string_padding +
    'separator: ' +self.separator.to_s
  end
end

ConcatParagraphGenerator.new.run