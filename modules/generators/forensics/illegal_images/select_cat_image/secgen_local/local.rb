#!/usr/bin/ruby
require_relative '../../../../../../lib/objects/local_string_generator.rb'
require 'date'

class SelectCatImage < StringGenerator
  attr_accessor :selected_image_path

  def initialize
    super
    self.module_name = 'Random cat image selector'
    self.selected_image_path = Dir["#{ILLEGAL_IMAGES_DIR}/cats/*"].sample
  end

  def get_options_array
    super + [['--selected_image_path', GetoptLong::OPTIONAL_ARGUMENT]]
  end

  def process_options(opt, arg)
    super
    case opt
      when '--selected_image_path'
        self.selected_image_path << arg;
    end
  end

  def generate
    file_contents = File.binread(self.selected_image_path)
    self.outputs << Base64.strict_encode64(file_contents)
  end
end

SelectCatImage.new.run