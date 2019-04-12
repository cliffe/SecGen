#!/usr/bin/ruby
require 'base64'
require 'rmagick'
require_relative '../../../../../lib/objects/local_string_encoder.rb'
class ImageGenerator < StringEncoder
  attr_accessor :selected_image_path

  def initialize
    super
    self.module_name = 'Random JPG Generator'
    self.selected_image_path = Dir["#{IMAGES_DIR}/misc/*"].sample
  end

  def encode_all
    # Grabs a random PNG from the resources + converts it to JPG with RMagick
    tmp_file_path = GENERATORS_DIR + 'image/random_jpg/secgen_local/tmp.jpg'

    images = Magick::ImageList.new
    images.read(self.selected_image_path)
    images.new_image(images.first.columns, images.first.rows) { self.background_color = 'white' } # Create new "layer" with white background and size of original image
    image = images.reverse.flatten_images

    image.write(tmp_file_path)

    self.outputs << Base64.strict_encode64(File.binread(tmp_file_path))
  end

  def encoding_print_string
    'Random image generator: ' + self.selected_image_path
  end
end

ImageGenerator.new.run