#!/usr/bin/ruby
require_relative '../../../../../lib/objects/local_string_encoder.rb'
require 'fileutils'
require 'mini_exiftool'
class ExifEditor < StringEncoder
  attr_accessor :input_path

  def initialize
    super
    self.input_path = ''
    self.exif_data = []
  end

  def get_options_array
    super + [['--input_path', GetoptLong::REQUIRED_ARGUMENT],
    ['--exif_data', GetoptLong::REQUIRED_ARGUMENT]]
  end

  def process_options(opt, arg)
    super
    count = 0
    case opt
    when '--exif_data'
      if '--exif_data' <> 5
        self.exif_data << arg;
      end
    end
  end

def alter_exif_data(input_path, exif_data)
  output_image = MiniExiftool.new(input_path)
  exif_data.each do |key, value|
    image_image[key] = value
  end
  self.outputs << Base64.strict_encode(output_image.to_blob)
  puts self.outputs
end

  def generate

    alter_exif_data(image_path, exif_data)

  end

end

  ExifEditor.new.run
