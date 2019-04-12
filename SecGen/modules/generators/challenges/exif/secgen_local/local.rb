#!/usr/bin/ruby
require_relative '../../../../../lib/objects/local_string_encoder.rb'
require 'mini_exiftool_vendored'

class ExifModifiedGenerator < StringEncoder
  attr_accessor :base64_image
  attr_accessor :strings_to_leak
  attr_accessor :exif_field

  def initialize
    super
    self.module_name = 'Modified Exif Image Generator'
    self.base64_image = ''
    self.strings_to_leak = []
    self.exif_field = ''
  end

  def encode_all
    # Decode the base64 image data into raw contents
    raw_image_contents = Base64.strict_decode64(self.base64_image)

    # Store the raw_image_contents as a temporary image file called 'tmp.jpg'
    tmp_file_path = GENERATORS_DIR + 'challenges/exif/secgen_local/tmp.jpg'
    File.open(tmp_file_path, 'wb') { |f| f.write(raw_image_contents) }

    image = MiniExiftool.new(tmp_file_path)
    image[self.exif_field] = self.strings_to_leak[0]
    image.save

    self.outputs << Base64.strict_encode64(File.binread(tmp_file_path))
  end

  def get_options_array
    super + [['--base64_image', GetoptLong::REQUIRED_ARGUMENT],
             ['--strings_to_leak', GetoptLong::REQUIRED_ARGUMENT],
             ['--exif_field', GetoptLong::REQUIRED_ARGUMENT]]
  end

  def process_options(opt, arg)
    super
    case opt
      when '--base64_image'
        self.base64_image << arg;
      when '--strings_to_leak'
        self.strings_to_leak << arg;
      when '--exif_field'
        self.exif_field << arg;
    end
  end

  def encoding_print_string
    'base64_image: <selected_image>' + print_string_padding +
    'strings_to_leak: ' + self.strings_to_leak.to_s + print_string_padding +
    'exif_field: ' + self.exif_field.to_s
  end
end

ExifModifiedGenerator.new.run