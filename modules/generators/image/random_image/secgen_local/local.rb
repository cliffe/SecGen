#!/usr/bin/ruby
require 'base64'
require_relative '../../../../../lib/objects/local_string_encoder.rb'
class ImageGenerator < StringEncoder
    attr_accessor :selected_image_path

  def initialize
    super
    self.module_name = 'Random Image Generator'
    self.selected_image_path = Dir["#{IMAGES_DIR}/misc/*"].sample
  end

  def encode_all
    file_contents = File.binread(self.selected_image_path)
    self.outputs << Base64.strict_encode64(file_contents)
  end

  def encoding_print_string
    'Random image generator: ' + self.selected_image_path
  end
end

ImageGenerator.new.run